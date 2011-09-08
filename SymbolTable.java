import java.util.HashMap;

class SymbolTable
{
    private HashMap<String,VarType> symbols;

    public SymbolTable()
    {
        symbols = new HashMap();
        System.out.println( "Created SymbolTable" );
    }

	public void add( String name )
	{
		add( name, VarType.UNKNOWN );
	}

    public void add( String name, VarType theType )
    {
        String key = name.toUpperCase();
        if ( symbols.containsKey(key) ) {
            if ( symbols.get(key) == VarType.UNKNOWN ) {
                symbols.put( key, theType );
            } else if ( symbols.get(key) != theType ) {
				// FIXME: mismatched types
			}
        } else {
			symbols.put( key, theType );
		}
    }

	public String toString()
	{
		return symbols.toString();
	}
}
