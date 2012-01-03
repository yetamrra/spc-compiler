import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class SymbolTable implements Scope
{
    private Map<String,SymEntry> symbols;
    Scope parentScope;
    String name;

    public SymbolTable( Scope parent, String name )
    {
    	parentScope = parent;
    	this.name = name;
        symbols = new HashMap<String,SymEntry>();
        System.out.println( "Created SymbolTable " + name + (parent == null ? "" : " inside parent " + parent.getScopeName()) );
    }

	/*
	public void add( String name, SymEntry theType, boolean declare )
	{
	    String key = name.toUpperCase();
        if ( symbols.containsKey(key) ) {
			SymEntry e = symbols.get(key);
            if ( e.varType == VarType.UNKNOWN ) {
				e.varType = theType;
                symbols.put( key, e );
            } else if ( e.varType != theType ) {
				// FIXME: mismatched types
			}
        } else {
			SymEntry e = new SymEntry();
			e.varType = theType;
			e.needsDeclaration = declare;
			symbols.put( key, e );
		}
	}*/

	public String toString()
	{
		return symbols.toString();
	}

	public List<String> getSt()
	{
		List<String> retVal = new ArrayList<String>();
		for ( Map.Entry<String, SymEntry> v : symbols.entrySet()) {
			//if ( v.getValue().needsDeclaration ) {
				retVal.add( v.getValue().varType + " " + v.getKey() );
			//}
		}
		return retVal;
	}

	@Override
	public String getScopeName() {
		if ( getParentScope() == null ) {
			return name;
		} else {
			return getParentScope().getScopeName() + "::" + name;
		}
	}

	@Override
	public Scope getParentScope() {
		return parentScope;
	}

	@Override
	public void define(SymEntry sym) {
		String name = sym.name.toUpperCase();
		symbols.put( name, sym );
		sym.scope = this;
	}

	@Override
	public SymEntry resolve(String name, boolean localOnly ) {
		String key = name.toUpperCase();
		SymEntry s = symbols.get( key );
		if ( !localOnly && s == null && getParentScope() != null ) {
			s = getParentScope().resolve( name, false );
		}
		return s;
	}
}
