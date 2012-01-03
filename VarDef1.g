tree grammar VarDef1;
options {
  tokenVocab = SpokenLang;
  ASTLabelType = SLTreeNode;
  filter = true;
}

@members {
    public Scope currentScope;
}

// Topdown and bottomup tell ANTLR which rules
// to process as it goes down and then up the tree.
topdown
    :   enterBlock
    |	enterFunction
    |	funcArgs
    |	assignment
    |	atom
    ;

bottomup
    :   exitBlock
    |	exitFunction
    ;

enterBlock
    :   BLOCK 
		{
			currentScope = new SymbolTable(currentScope, "block");
		}
    ;

exitBlock
    :   BLOCK
    	{
        	System.out.println("locals in " + currentScope.getScopeName() + ": "+currentScope);
        	currentScope = currentScope.getParentScope();
    	}
    ;

enterFunction
	:	^(FUNCTION ID .*)
		{
			// Make a symbol entry for the function.
			SymEntry chk = currentScope.resolve( $ID.text, true );
			if ( chk != null ) {
				throw new CompileException( "Duplicate definition of " + $ID.text );
			}
			SymEntry sym = new SymEntry( $ID.text, VarType.UNKNOWN, currentScope );
			sym.definition = $ID;
			$ID.symbol = sym;
			currentScope.define( sym );
			
			// Make new scope for the function
			currentScope = new SymbolTable(currentScope, $ID.text);
		}
    ;
	
exitFunction
	:	FUNCTION
	   	{
        	System.out.println("locals in " + currentScope.getScopeName() + ": "+currentScope);
        	currentScope = currentScope.getParentScope();
    	}
	;
	
funcArgs
	:	^(ARG_LIST args+=ID+)
		{
			for ( Object a: $args ) {
				SLTreeNode var = (SLTreeNode)a;
				SymEntry sym = new SymEntry( var.getText(), VarType.UNKNOWN, currentScope );
				sym.definition = var;
				var.symbol = sym;
				currentScope.define( sym );
			}
		}
	;

assignment
	:	^(ASSIGN ID .)
		{
			SymEntry var = currentScope.resolve( $ID.text, false );
			if ( var == null ) {
				var = new SymEntry( $ID.text, VarType.UNKNOWN, currentScope );
				var.definition = $ID;
				$ID.symbol = var;
				currentScope.define( var );
			}
		}
	;
	
// Set scope for atoms in expressions, but don't define them
atom
	@init {SLTreeNode t = (SLTreeNode)input.LT(1);}
    :	{t.hasAncestor(EXPR)}?
    	ID
       	{
       		System.out.println( "Setting scope of " + $ID.text + " to " + currentScope.getScopeName() );
       		t.scope = currentScope;
       	}
	;
