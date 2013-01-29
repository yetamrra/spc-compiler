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
