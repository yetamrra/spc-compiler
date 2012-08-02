package org.bxg.spokencompiler;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.*;
import java.io.*;

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
	
			// Produce intermediate output into java file
			// FIXME: write to tmp file instead of hardcoded name
			StringTemplate output = (StringTemplate)strTmpl.getTemplate();
			System.out.println( output.toStructureString() );
			//System.out.println( output.toString() );
			FileWriter outFile = new FileWriter( outName );
			outFile.write( output.toString() );
			outFile.close();
		}
		catch ( RecognitionException e ) {
			throw new CompileException( e.getMessage() );
		}

		System.out.println( "-- Compiling " + outName + " --" );
		// Run the Java compiler on the intermediate file
		JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
		int results = compiler.run( null, null, null, outName );
		if ( results != 0 ) {
			throw new CompileException("Compile failed.  Intermediate output in " + outName);
		}

		// Remove the intermediate file if the compile succeeded
		File f = new File( outName );
		f.delete();
		System.out.println( "-- Succeeded.  Output in " + className + ".class --" );		
	}
	
	public static void main( String[] args ) throws Exception
	{
		SpokenCompiler c = new SpokenCompiler();
		for ( String fileArg: args ) {
			try {
				c.compileFile( fileArg, "SLJavaEmitter.stg" );
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
