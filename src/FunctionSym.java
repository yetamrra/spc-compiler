class FunctionSym extends SymEntry
{
    public VarType returnType;

    public FunctionSym( String name, Scope scope )
    {
        super( name, VarType.FUNCTION, scope );
        returnType = VarType.UNKNOWN;
    }

    public String toString()
    {
        return name + "<function:" + returnType + "> (defined at line " + definition.getLine() + ")";
    }
}
