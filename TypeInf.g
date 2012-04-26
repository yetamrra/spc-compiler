tree grammar TypeInf;
options {
  tokenVocab = SpokenLang;
  ASTLabelType = SLTreeNode;
  filter = true;
}

@members {
    public Scope currentScope;
	public List constraints;

    void constrainType( SLTreeNode node, VarType vType )
    {
        if ( node.symbol == null ) {
            System.err.println( "Undefined variable " + node.getText() );
            System.exit( 1 );
        } else if ( node.symbol.varType == VarType.UNKNOWN ) {
            // Unknown type.  Set it if we can or add a constraint.
            if ( vType != VarType.UNKNOWN ) {
                System.out.println( "Setting type of " + node.getText() + " to " + vType );
                node.symbol.varType = vType;
            } else {
                System.out.println("Constraint: typeof(" + node.getText() + ") = " + vType ); // "[" + rhs.getText() + "]"); }
            }
        } else {
            // Already has a known type.  Make sure they match.
            if ( node.symbol.varType != vType ) {
                System.err.println( "Variable " + node.getText() + " of type " + node.symbol.varType + " not compatible with type " + vType );
                System.exit( 1 );
            }
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

bottomup
    :   exprRoot
	|	assignment
    ;

assignment
	:	^(ASSIGN ID rhs=.) { constrainType( $ID, $rhs.evalType ); }
	;

exprRoot returns [VarType type]
	:	^(EXPR expr) { $type = $EXPR.evalType = $expr.type; }
	;

expr returns [VarType type]
@after { System.out.println( "typeof(" + $expr.text + ") = " + $type ); }
	: atom { $type = $atom.type; }
	;

// Set scope for atoms in expressions, but don't define them
atom returns [VarType type]
	:	INT 	{ $type = VarType.INT; }
	|	FLOAT 	{ $type = VarType.FLOAT; }
	|	STRING 	{ $type = VarType.STRING; }
	|	ID		
		{ 
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
		   	} else {
				$type = $b.start.evalType;
				System.out.println( "Constraint: typeof(" + $a.text + ") = " + $b.type );
			}
		}
	;

binop : '+' | '-' | '*' | '/' ;
