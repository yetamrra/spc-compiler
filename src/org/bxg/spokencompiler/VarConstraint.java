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
