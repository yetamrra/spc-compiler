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

import java.util.LinkedList;
import java.util.List;

class FunctionSym extends SymEntry
{
    public VarType returnType;
    public List<SymEntry> arguments;

    public FunctionSym( String name, Scope scope )
    {
        super( name, VarType.FUNCTION, scope );
        returnType = VarType.UNKNOWN;
        arguments = new LinkedList<SymEntry>();
    }

    public void addArgument( SymEntry arg )
    {
    	arguments.add( arg );
    }
    
    public String toString()
    {
        return name + "<function:" + returnType + "> (defined at line " + definition.getLine() + ")";
    }
}
