/*
 * Copyright 2012-2014 Benjamin M. Gordon
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
