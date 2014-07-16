/*
 * Copyright 2011-2014 Benjamin M. Gordon
 * 
 * This file is part of the spoken language compiler.
 *
 * The spoken language compiler is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The spoken language compiler is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the spoken language compiler.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.bxg.spokencompiler;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.*;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.jar.Attributes;
import java.util.jar.JarEntry;
import java.util.jar.JarOutputStream;
import java.util.jar.Manifest;

import javax.tools.JavaCompiler;
import javax.tools.ToolProvider;

public class SpokenCompiler
{
	private CommonTreeNodeStream nodes;
	private SymbolTable symTree;
	
	private String className;

	public String getClassName() {
		return className;
	}

	private void setClassName(String className) {
		this.className = className;
	}

	private PrintStream msgLog;

	public PrintStream getMsgLog() {
		return msgLog;
	}

	public void setMsgLog(PrintStream msgLog) {
		this.msgLog = msgLog;
	}

	// OutputStream that discards all output.  Used so that
	// the default log output can go nowhere.
	private class NullOutputStream extends OutputStream
	{
		@Override
		public void write(int b) throws IOException {}

		@Override
		public void write(byte[] b) throws IOException {}

		@Override
		public void write(byte[] b, int off, int len) throws IOException {}
	}

	public SpokenCompiler()
	{
		className = "";
		nodes = null;
		symTree = null;
		msgLog = new PrintStream( new NullOutputStream() );
	}

	public void parseFile( String sourceFile ) throws CompileException, IOException
	{
		// Reset for re-parsing
		nodes = null;
		symTree = null;
		
		// Figure out file names
		setClassName( sourceFile.replaceAll("(.*/)?([^/]+)\\.spk$","$2") );

		try {
			// Parse input into AST
			ANTLRFileStream input = new ANTLRFileStream( sourceFile );
			SpokenLangLexer lexer = new SpokenLangLexer( input );
			CommonTokenStream tokens = new CommonTokenStream( lexer );
			SpokenLangParser parser = new SpokenLangParser( tokens );
			SLTreeAdaptor treeAdaptor = new SLTreeAdaptor();
			parser.setTreeAdaptor( treeAdaptor );
			SpokenLangParser.program_return ast = parser.program();
			if ( parser.getNumberOfSyntaxErrors() > 0 ) {
				throw new CompileException("Error parsing input");
			}
			SLTreeNode t = (SLTreeNode)ast.getTree();
			//msgLog.println( "AST: " + t.toStringTree() );
	
			// Walk tree to do variable resolution
			msgLog.println( "-- Resolving symbol references --" );
			nodes = new CommonTreeNodeStream(treeAdaptor, t);
			nodes.setTokenStream( tokens );
			symTree = new SymbolTable( null, "global" );	// Global scope
			VarDef1 def = new VarDef1( nodes );		// Pass 1 - find vars and populate symbol table
			def.currentScope = symTree;
			def.downup(t);                          // Do pass 1
			nodes.reset(); // rewind AST node stream to root
			//Ref ref = new Ref(nodes);               // Pass 2 - resolve references
			//ref.downup(t);                          // Do pass 2
			//msgLog.println( symTree.toStringNested(0) );
	
			msgLog.println( "-- Inferring types --" );
			TypeInf ti = new TypeInf(nodes);
			ti.downup(t);
			ti.processConstraints( true );  // process outstanding type constraints
			//msgLog.println( symTree.toStringNested(0) );
		}
		catch ( RecognitionException e ) {
			throw new CompileException( e.getMessage() );
		}
	}
	
	public String generateCode( String templateFile ) throws CompileException, IOException
	{
		if ( nodes == null || symTree == null ) {
			throw new CompileException("You must call parseFile() before calling generateCode()");
		}

		// Read string templates
		InputStream in = getClass().getResourceAsStream( templateFile );
		InputStreamReader tr = new InputStreamReader(in);
		StringTemplateGroup templates = new StringTemplateGroup( tr );
		tr.close();

		// Generate output into String
		String retVal = null;
		try {
			nodes.reset();
			SLJavaEmitter emitter = new SLJavaEmitter( nodes );
			emitter.setTemplateLib( templates );
			SLJavaEmitter.program_return strTmpl = emitter.program( className, symTree );
			if ( emitter.getNumberOfSyntaxErrors() > 0 ) {
				throw new CompileException("Error parsing AST");
			}

			StringTemplate output = (StringTemplate)strTmpl.getTemplate();
			retVal = output.toString();
		}
		catch ( RecognitionException e ) {
			throw new CompileException( e.getMessage() );
		}
		
		return retVal;
	}
	
	public void createJar( String javaCode, String jarName ) throws CompileException, IOException
	{
		// Produce intermediate output into java file in a temporary directory
		String genJavaName = getClassName() + ".java";
		Path tmpDirPath = Files.createTempDirectory("spc");
		String tmpPath = tmpDirPath.toString() + File.separator + genJavaName;
		File tmpDir = tmpDirPath.toFile();
		tmpDir.deleteOnExit();
		
		//msgLog.println( output.toStructureString() );
		FileWriter outFile = new FileWriter( tmpPath );
		outFile.write( javaCode );
		outFile.close();
		
		// Run the Java compiler on the intermediate file
		JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
		int results = compiler.run( null, null, null, tmpPath );
		if ( results != 0 ) {
			throw new CompileException("Compile failed.  Intermediate output in " + tmpPath);
		}

		// Pull the files from the tmpdir back into a jar
		Manifest mf = new Manifest();
		mf.getMainAttributes().put( Attributes.Name.MANIFEST_VERSION, "1.0" );
		mf.getMainAttributes().put( Attributes.Name.MAIN_CLASS, className );
		JarOutputStream jar = new JarOutputStream( new FileOutputStream(jarName), mf );
		for ( File classFile: tmpDir.listFiles() ) {
			if ( !classFile.getName().endsWith(".class") ) {
				// Clean up extra files
				classFile.delete();
				continue;
			}
			JarEntry entry = new JarEntry(classFile.getName());
			entry.setTime(classFile.lastModified());
		    jar.putNextEntry(entry);
		    Files.copy( classFile.getAbsoluteFile().toPath(), jar );
		    jar.closeEntry();
		    classFile.delete();	// Clean up temporary files
		}
		jar.close();
	}
	
	public static void main( String[] args ) throws Exception
	{
		SpokenCompiler c = new SpokenCompiler();
		PrintStream msgLog = System.out;
		c.setMsgLog(msgLog);

		for ( String fileArg: args ) {
			try {
				msgLog.println( "-- Parsing input file " + fileArg + "  --");
				c.parseFile( fileArg );
	
				msgLog.println( "-- Generating code --" );
				String javaCode = c.generateCode( "/SLJavaEmitter.stg" );

				msgLog.println( "-- Compiling " + c.getClassName() + ".java --" );
				String jarName = fileArg.replaceAll( "\\.spk$", ".jar" );
				c.createJar( javaCode, jarName );
				msgLog.println( "-- Succeeded.  Output in " + c.getClassName() + ".jar --" );
			}
			catch ( CompileException e ) {
				System.err.println( "Error compiling " + fileArg + ": " + e.getMessage() );
				System.exit( 1 );
			}
			catch ( IOException e ) {
				System.err.println( "Error compiling " + fileArg + ": " + e.getMessage() );
				System.exit( 1 );
			}
		}
	}
}
