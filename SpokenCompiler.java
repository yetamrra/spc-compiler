import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.*;
import java.io.*;
import javax.tools.JavaCompiler;
import javax.tools.ToolProvider;

public class SpokenCompiler
{
	public static void main( String[] args ) throws Exception
	{
		String inName = args[0];
		String className = inName.replaceAll("\\.spk$","");
		String outName = inName.replaceAll( "\\.spk$", ".java" );

		try {
			// Read string templates
			FileReader tr = new FileReader( "SLJavaEmitter.stg" );
			StringTemplateGroup templates = new StringTemplateGroup( tr );
			tr.close();

			// Parse input into AST
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

			// Walk tree to do variable resolution
			SLTreeNode t = (SLTreeNode)ast.getTree();
			System.out.println( "AST: " + t.toStringTree() );
	        CommonTreeNodeStream nodes = new CommonTreeNodeStream(treeAdaptor, t);
	        nodes.setTokenStream( tokens );
	        SymbolTable symTree = new SymbolTable( null, "global" );	// Global scope
	        VarDef1 def = new VarDef1( nodes );		// Pass 1 - find vars and populate symbol table
	        def.currentScope = symTree;
	        def.downup(t);                          // Do pass 1
	        System.out.println("globals: "+symTree);
	        nodes.reset(); // rewind AST node stream to root
	        //Ref ref = new Ref(nodes);               // create Ref phase
	        //ref.downup(t);                          // Do pass 2

	        System.exit( 1 );
	        
			// Generate output into String variable
			nodes.reset();
			SLJavaEmitter emitter = new SLJavaEmitter( nodes );
			emitter.setTemplateLib( templates );
			SLJavaEmitter.program_return strTmpl = emitter.program( className );
			if ( emitter.getNumberOfSyntaxErrors() > 0 ) {
				throw new CompileException("Error parsing AST");
			}

			// Produce intermediate output into java file
			// FIXME: write to tmp file instead of hardcoded name
			StringTemplate output = (StringTemplate)strTmpl.getTemplate();
			FileWriter outFile = new FileWriter( outName );
			outFile.write( output.toString() );
			outFile.close();

			// Run the Java compiler on the intermediate file
			JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
			int results = compiler.run( null, null, null, outName );
			if ( results == 0 ) {
				throw new CompileException("Compile failed.  Intermediate output in " + outName);
			}

			// Remove the intermediate file if the compile succeeded
			File f = new File( outName );
			//f.delete();
		}
		catch ( CompileException e ) {
			System.err.println( e.getMessage() );
			System.exit( 1 );
		}
	}
}
