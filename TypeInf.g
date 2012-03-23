tree grammar TypeInf;
options {
  tokenVocab = SpokenLang;
  ASTLabelType = SLTreeNode;
  filter = true;
}

@members {
    public Scope currentScope;
	public List constraints;
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
	:	^(ASSIGN ID rhs=.) { System.out.println("Constraint: typeof(" + $ID.text + ") = " + $rhs.evalType + "[" + $rhs.getText() + "]"); }
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
