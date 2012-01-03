import org.antlr.runtime.Token;
import org.antlr.runtime.tree.CommonTree;


public class SLTreeNode extends CommonTree
{
	public Scope scope;		// Scope where this node was defined
	public SymEntry symbol;	// Points to symbol table if this is a Symbol node
	
	public SLTreeNode( Token t )
	{
		super( t );
	}
}
