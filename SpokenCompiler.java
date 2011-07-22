import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import org.antlr.stringtemplate.*;
import java.io.*;

public class SpokenCompiler
{
    public static void main( String[] args ) throws Exception
    {
        // Read string templates
        FileReader tr = new FileReader( "SLJavaEmitter.stg" );
	StringTemplateGroup templates = new StringTemplateGroup( tr );
	tr.close();

        // Parse input into AST
	ANTLRFileStream input = new ANTLRFileStream( args[0] );
	SpokenLangLexer lexer = new SpokenLangLexer( input );
	CommonTokenStream tokens = new CommonTokenStream( lexer );
	SpokenLangParser parser = new SpokenLangParser( tokens );
	SpokenLangParser.program_return ast = parser.program();

	// Generate output into String variable
	CommonTree t = (CommonTree)ast.getTree();
	System.out.println( "AST: " + t.toStringTree() );
	CommonTreeNodeStream nodes = new CommonTreeNodeStream(t);
	nodes.setTokenStream( tokens );
	SLJavaEmitter emitter = new SLJavaEmitter( nodes );
	emitter.setTemplateLib( templates );
	SLJavaEmitter.program_return strTmpl = emitter.program();

	// Produce output
	StringTemplate output = (StringTemplate)strTmpl.getTemplate();
        if ( args.length > 2 && args[1].equals("-o")) {
            FileWriter outFile = new FileWriter( args[2] );
            outFile.write( output.toString() );
            outFile.close();
        } else {
            System.out.println( output.toString() );
        }
    }
}
