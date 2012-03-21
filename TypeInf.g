tree grammar TypeInf;
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
/*topdown
    :   enterBlock
    |	enterFunction
    |	funcArgs
    |	assignment
    |	atom
    ;*/

bottomup
    :   expr
    ;

expr returns [VarType type]
	@after { System.out.println( "typeof(" + $expr.text + ") = " + $type ); }
	: ^(EXPR atom) { $type = $atom.type; }
	;

// Set scope for atoms in expressions, but don't define them
atom returns [VarType type]
	: INT 		{ $type = VarType.INT; }
	| FLOAT 	{ $type = VarType.FLOAT; }
	| STRING 	{ $type = VarType.STRING; }
	| ID		{ $type = VarType.UNKNOWN; }
	;
