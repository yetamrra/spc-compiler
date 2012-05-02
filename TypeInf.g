tree grammar TypeInf;
options {
  tokenVocab = SpokenLang;
  ASTLabelType = SLTreeNode;
  filter = true;
}

@members {
    public Scope currentScope;
	public List constraints;
    public SLTreeNode currentFunction;

    VarType matchTypes( VarType knownType, VarType matchType, SLTreeNode node )
    {
        if ( knownType == VarType.UNKNOWN ) {
            // If the LHS is unknown then the type it should be
            // set to is the RHS
            return matchType;
        } else {
            // The LHS has a known type, so make sure they match
            if ( matchType != VarType.UNKNOWN && knownType != matchType ) {
                throw new CompileException( "Incompatible types " + knownType + " and " + matchType + " for " + node.getText() + " at line " + node.getLine() );
            } else {
                return knownType;
            }
        }
    }

    void constrainType( SLTreeNode node, VarType vType )
    {
        if ( node.symbol == null ) {
            throw new CompileException( "Unresolved variable " + node.getText() + " at line " + node.getLine() );
        } else if ( node.symbol.varType == VarType.FUNCTION ) {
            // Setting the return type of a function.  Use the returnType instead of
            // varType
            FunctionSym f = (FunctionSym)node.symbol;
            VarType t = matchTypes( f.returnType, vType, node );
            if ( t != VarType.UNKNOWN ) {
                f.returnType = t;
				System.out.println( "Constraint: typeof(" + node.getText() + ") = " + vType );
                // FIXME: add constraint
            }
        } else {
            // Try to set the variable type
            SymEntry s = node.symbol;
            VarType t = matchTypes( s.varType, vType, node );
            if ( t != VarType.UNKNOWN ) {
                s.varType = t;
				System.out.println( "Constraint: typeof(" + node.getText() + ") = " + vType );
                // FIXME: add constraint
            }
        }
    }

    VarType getFuncType( SLTreeNode node )
    {
        // Make sure node represents a function and then
        // return its returnType.
        if ( node.symbol == null ) {
            // Try to resolve the function.  It would have been previously skipped
            // if it was a forward reference.
            SymEntry var = currentFunction.scope.resolve( node.getText(), false );
            if ( var == null ) {
                throw new CompileException( "Unresolved function " + node.getText() + " at line " + node.getLine() );
            } else {
                node.symbol = var;
            }
        }
        
        if ( node.symbol.varType == VarType.FUNCTION ) {
            return ((FunctionSym)node.symbol).returnType;
        } else {
            throw new CompileException( "Can't call non-function symbol " + node.getText() + " at line " + node.getLine() );
        }
    }
}

// Topdown and bottomup tell ANTLR which rules
// to process as it goes down and then up the tree.
/*topdown
    :   enterBlock
    |	enterFunction
    |	funcArgs
    |	assignment
    |	atom
    ;*/

topdown
    :   enterFunction
    ;

bottomup
    :   exprRoot
	|	assignment
    |   returnStmt
    |   callStmt
    |   exitFunction
    ;

assignment
	:	^(ASSIGN ID rhs=.) { constrainType( $ID, $rhs.evalType ); }
	;

returnStmt
    :   ^(RETURN rhs=.) { constrainType( currentFunction, $rhs.evalType ); }
    ;

callStmt returns [VarType type]
    :   ^(CALL ID .*) { $type = $CALL.evalType = getFuncType($ID); }
    ;

exprRoot returns [VarType type]
	:	^(EXPR expr) { $type = $EXPR.evalType = $expr.type; }
	;

expr returns [VarType type]
@after { System.out.println( "typeof(" + $expr.text + ") = " + $type ); }
	: atom { $type = $atom.type; }
    | callStmt { $type = $callStmt.type; }
	;
 
enterFunction
    :   ^(FUNCTION ID .*)
        {
            currentFunction = $ID;
            if ( currentFunction.symbol == null ) {
                throw new CompileException( "Unresolved function " + $ID.text + " entered at line " + $ID.line );
            }
        }
    ;

exitFunction
    :   FUNCTION
        {
            // If the function's type is unknown, set it to void
            // FIXME: We probably can't set this to void in the general case
            if ( ((FunctionSym)currentFunction.symbol).returnType == VarType.UNKNOWN ) {
                constrainType( currentFunction, VarType.VOID );
            }
        }
    ;

// Set scope for atoms in expressions, but don't define them
atom returns [VarType type]
	:	INT 	{ $type = VarType.INT; }
	|	FLOAT 	{ $type = VarType.FLOAT; }
	|	STRING 	{ $type = VarType.STRING; }
	|	ID		
		{ 
            System.out.println( "Found ID " + $ID.text );
			if ( $ID.symbol == null ) {
				SymEntry s = $ID.scope.resolve( $ID.text, false );
				$ID.symbol = s;
			}

			$type = $ID.symbol.varType; 
		}
	|	binaryOp { $type = $binaryOp.type; }
	;

binaryOp returns [VarType type]
@after { $start.evalType = $type; }
	: 	binop a=exprRoot b=exprRoot 
		{ 
			if ( $a.type != VarType.UNKNOWN ) {
				$type = $a.start.evalType;
                if ( $b.start.symbol != null ) {
                    constrainType( $b.start, $a.start.evalType );
                }
		   	} else {
				$type = $b.start.evalType;
                if ( $a.start.symbol != null ) {
                    constrainType( $a.start, $b.start.evalType );
                }
			}
		}
	;

binop : '+' | '-' | '*' | '/' ;
