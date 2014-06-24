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

enum VarType
{
    UNKNOWN
    , INT
    , FLOAT
    , STRING
    , FUNCTION
    , VOID
    , BOOLEAN
    , ARRAY
    ;

    public VarType subType;
    
    public String toString()
    {
        switch ( this ) {
            case UNKNOWN:
                return super.toString();

            case ARRAY:
            	return "array of " + subType.toString();
            	
            default:
                return super.toString().toLowerCase();
        }
    }

    public String getJavaType()
    {
        switch ( this ) {
            case UNKNOWN:
                return super.toString();

            case STRING:
                return "java.lang.String";

            case ARRAY:
            	return subType.getJavaType() + "[]";
            	
            default:
                return super.toString().toLowerCase();
        }
    }
    
    public String getJavaObjectType()
    {
    	switch ( this ) {
    		case UNKNOWN:
    			return "UNKNOWN";
    			
    		case STRING:
    			return "String";
    			
    		case ARRAY:
    			return subType.getJavaObjectType() + "[]";
    			
    		case INT:
    			return "Integer";
    			
    		default:
    			return "FIXME: " + super.toString();
    	}
    }
};
