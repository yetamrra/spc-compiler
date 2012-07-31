package org.bxg.spokencompiler;

import org.antlr.runtime.Token;
import org.antlr.runtime.tree.CommonTree;


public class SLTreeNode extends CommonTree
{
	public Scope scope;			// Scope where this node was defined
	public SymEntry symbol;		// Points to symbol table if this is a Symbol node
	public VarType evalType;	// Type of this node, if it has one
	
	public SLTreeNode( Token t )
	{
		super( t );
	}
}
