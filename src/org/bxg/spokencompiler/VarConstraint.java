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

class VarConstraint
{
    public SymEntry v1;
    public SymEntry v2;

    public VarConstraint( SymEntry s1, SymEntry s2 )
    {
        v1 = s1;
        v2 = s2;
    }

    public boolean equals( VarConstraint rhs )
    {
        return (v1 == rhs.v1 && v2 == rhs.v2)
               ||
               (v2 == rhs.v1 && v1 == rhs.v2)
               ;
    }

    public String toString()
    {
        return "typeof(" + v1.scope.getScopeName() + "::" + v1.name + 
               ") = typeof(" + v2.scope.getScopeName() + "::" + v2.name + ")";
    }
}
