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

class SymEntry
{
	public String name;
	public VarType varType;
	public Scope scope;
	public SLTreeNode definition;
	public boolean isArray;

	public SymEntry( String name, VarType varType, Scope scope )
	{
		this.name = name;
		this.varType = varType;
		this.scope = scope;
		this.isArray = false;
	}
	
	public String toString()
	{
		return name + "<" + varType + (isArray ? "[]" : "") + "> (defined at line " + definition.getLine() + ")"; 
	}
}
