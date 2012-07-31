class SymEntry
{
	public String name;
	public VarType varType;
	public Scope scope;
	public SLTreeNode definition;

	public SymEntry( String name, VarType varType, Scope scope )
	{
		this.name = name;
		this.varType = varType;
		this.scope = scope;
	}
	
	public String toString()
	{
		return name + "<" + varType + "> (defined at line " + definition.getLine() + ")"; 
	}
}
