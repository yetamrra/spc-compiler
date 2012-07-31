package org.bxg.spokencompiler;

import org.antlr.runtime.Token;
import org.antlr.runtime.tree.CommonTreeAdaptor;


public class SLTreeAdaptor extends CommonTreeAdaptor
{
	public Object create(Token token) {
		return new SLTreeNode(token);
	}
	
	public Object dupNode(Object t) {
		if ( t==null ) {
			return null;
		}
		return create(((SLTreeNode)t).token);
	}
	
	/*
	public Object errorNode(TokenStream input, Token start, Token stop,
			RecognitionException e)
	{
		CymbolErrorNode t = new CymbolErrorNode(input, start, stop, e);
		//System.out.println("returning error node '"+t+"' @index="+input.index());
		return t;
	}*/
};

