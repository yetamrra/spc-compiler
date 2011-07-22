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
        // Read string templates
        FileReader tr = new FileReader( "SLJavaEmitter.stg" );
	StringTemplateGroup templates = new StringTemplateGroup( tr );
	tr.close();

        // Parse input into AST
        String inName = args[0];
	String className = inName.replaceAll("\\.spk$","");
	ANTLRFileStream input = new ANTLRFileStream( inName );
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
	SLJavaEmitter.program_return strTmpl = emitter.program( className );

	// Produce intermediate output into java file
        // FIXME: write to tmp file instead of hardcoded name
	StringTemplate output = (StringTemplate)strTmpl.getTemplate();
        String outName = inName.replaceAll( "\\.spk$", ".java" );
        FileWriter outFile = new FileWriter( outName );
        outFile.write( output.toString() );
        outFile.close();

        // Run the Java compiler on the intermediate file
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        int results = compiler.run( null, null, null, outName );

	// Remove the intermediate file if the compile succeeded
	if ( results == 0 ) {
	    File f = new File( outName );
	    f.delete();
	} else {
	    System.err.println( "Compile failed.  Intermediate file in " + outName );
	    System.exit( 1 );
	}
    }
}
