import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Map;

class SymbolTable
{
    private HashMap<String,SymEntry> symbols;

    public SymbolTable()
    {
        symbols = new HashMap();
        System.out.println( "Created SymbolTable" );
    }

	public void add( String name )
	{
		add( name, VarType.INT );
	}

    public void add( String name, VarType theType )
    {
		add( name, theType, true );
    }

	public void add( String name, VarType theType, boolean declare )
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
	}

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
}
