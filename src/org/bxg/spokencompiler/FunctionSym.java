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
