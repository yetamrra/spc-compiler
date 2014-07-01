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

import javax.tools.JavaCompiler;
import javax.tools.ToolProvider;

public class SpokenCompiler
{
	private StringTemplateGroup templates;

	public void compileFile( String fileName, String templateName ) throws CompileException, IOException
	{
		// Figure out file names
		String inName = fileName;
		String className = inName.replaceAll("(.*/)?([^/]+)\\.spk$","$2");
		String outName = inName.replaceAll( "\\.spk$", ".java" );
		String outPath = null;

		// Read string templates
		FileReader tr = new FileReader( templateName );
	    templates = new StringTemplateGroup( tr );
		tr.close();

		try {
			// Parse input into AST
			System.out.println( "-- Parsing input file " + inName + "  --");
			ANTLRFileStream input = new ANTLRFileStream( inName );
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
			System.out.println( "AST: " + t.toStringTree() );
	
			// Walk tree to do variable resolution
			System.out.println( "-- Resolving symbol references --" );
			CommonTreeNodeStream nodes = new CommonTreeNodeStream(treeAdaptor, t);
			nodes.setTokenStream( tokens );
			SymbolTable symTree = new SymbolTable( null, "global" );	// Global scope
			VarDef1 def = new VarDef1( nodes );		// Pass 1 - find vars and populate symbol table
			def.currentScope = symTree;
			def.downup(t);                          // Do pass 1
			nodes.reset(); // rewind AST node stream to root
			//Ref ref = new Ref(nodes);               // Pass 2 - resolve references
			//ref.downup(t);                          // Do pass 2
			System.out.println( symTree.toStringNested(0) );
	
			System.out.println( "-- Inferring types --" );
			TypeInf ti = new TypeInf(nodes);
			ti.downup(t);
			ti.processConstraints( true );  // process outstanding type constraints
			System.out.println( symTree.toStringNested(0) );
	
			System.out.println( "-- Generating code --" );
			// Generate output into String variable
			nodes.reset();
			SLJavaEmitter emitter = new SLJavaEmitter( nodes );
			emitter.setTemplateLib( templates );
			SLJavaEmitter.program_return strTmpl = emitter.program( className, symTree );
			if ( emitter.getNumberOfSyntaxErrors() > 0 ) {
				throw new CompileException("Error parsing AST");
			}
	
			// Produce intermediate output into java file in a temporary directory
			Path tmpDir = Files.createTempDirectory("spc");
			outPath = tmpDir.toString() + File.separator + outName;
			tmpDir.toFile().deleteOnExit();
			StringTemplate output = (StringTemplate)strTmpl.getTemplate();
			System.out.println( output.toStructureString() );
			//System.out.println( output.toString() );
			FileWriter outFile = new FileWriter( outPath );
			outFile.write( output.toString() );
			outFile.close();
		}
		catch ( RecognitionException e ) {
			throw new CompileException( e.getMessage() );
		}

		System.out.println( "-- Compiling " + outName + " --" );
		// Run the Java compiler on the intermediate file
		JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
		int results = compiler.run( null, null, null, outPath );
		if ( results != 0 ) {
			throw new CompileException("Compile failed.  Intermediate output in " + outPath);
		}

		// FIXME: Pull the files from the tmpdir back into a jar
		
		System.out.println( "-- Succeeded.  Output in " + className + ".class --" );		
	}
	
	public static void main( String[] args ) throws Exception
	{
		SpokenCompiler c = new SpokenCompiler();
		for ( String fileArg: args ) {
			try {
				c.compileFile( fileArg, "bin/SLJavaEmitter.stg" );
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
