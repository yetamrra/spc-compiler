tree grammar VarDef1;
options {
  tokenVocab = SpokenLang;
  ASTLabelType = SLTreeNode;
  filter = true;
}

@header {
	package org.bxg.spokencompiler;
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
    |   callStmt
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
				throw new CompileException( "Duplicate definition of " + $ID.text + " at line " + $ID.line );
			}
			SymEntry sym = new FunctionSym( $ID.text, currentScope );
			sym.definition = $ID;
			$ID.symbol = sym;
            $ID.scope = currentScope;
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
				currentScope.define( var );
			} else {
                if ( var.varType == VarType.FUNCTION ) {
                    throw new CompileException( "Attempted to assign a value to function " + $ID.text + " at line " + $ID.line );
                }
            }
			$ID.symbol = var;
		}
	|	^(ASSIGN ^(ARRAYREF idx=atom arr=ID) .)
		{
			SymEntry var = currentScope.resolve( $arr.text, false );
			if ( var == null ) {
				var = new SymEntry( $arr.text, VarType.UNKNOWN, currentScope );
				var.isArray = true;
				var.definition = $arr;
				currentScope.define( var );
			} else {
                if ( var.varType == VarType.FUNCTION ) {
                    throw new CompileException( "Attempted to assign a value to function " + $arr.text + " at line " + $arr.line );
                }
            }
			$arr.symbol = var;
		}	
	;

callStmt
	:	^(CALL ID .*)
		{
			SymEntry var = currentScope.resolve( $ID.text, false );
			if ( var == null ) {
                // This must be a forward reference.  Leave it alone for now.
                //throw new CompileException( "Attempted to call undefined function " + $ID.text + " at line " + $ID.line );
			} else {
                if ( var.varType != VarType.FUNCTION ) {
                    throw new CompileException( "Attempted to use symbol " + $ID.text + " as a function at line " + $ID.line );
                } else {
			        $ID.symbol = var;
                }
            }
		}
	;

// Set scope for atoms in expressions and array references, but don't define them
atom
	@init {SLTreeNode t = (SLTreeNode)input.LT(1);}
    :	{t.hasAncestor(EXPR) || t.hasAncestor(ARRAYREF) || t.hasParent(ASSIGN)}?
    	ID
       	{
       		System.out.println( "Setting scope of " + $ID.text + " to " + currentScope.getScopeName() + " at line " + $ID.getLine() );
       		t.scope = currentScope;
       	}
	;
