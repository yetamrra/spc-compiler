tree grammar SLJavaEmitter;

options {
    tokenVocab=SpokenLang;
    ASTLabelType=SLTreeNode;
    output=template;
}

program [String name,Scope symbols]
	:	f+=function+ { System.out.println("func"); } -> program(fList={$f},name={$name}) ;

function
	:	^(FUNCTION ID argList functionBody)	-> function(name={$ID.text},params={$argList.st},body={$functionBody.st},locals={""})
	|	^(FUNCTION ID functionBody)		-> function(name={$ID.text},body={$functionBody.st},locals={""})
	;

argList
	:	^(ARG_LIST args+=(ID)+ ) -> arglist(args={""})
	;

functionBody
        :       ^(BLOCK el+=stmt+) -> block(body={$el})
        ;

stmt    
	:       assignment -> {$assignment.st}
	|	printStmt -> {$printStmt.st}
	|	whileStmt -> {$whileStmt.st}
        ;

whileStmt
	:	^(WHILE boolExpr functionBody) -> while(guard={$boolExpr.st},body={$functionBody.st}) ;
	
printStmt
	:	^(PRINT expr) -> printOut(string={$expr.st})
	|	PRINTLN -> printOut(string={"\"\\n\""})
	;

callStmt
	:	^(CALL ID args=expr*)
	->	funcCall(func={$ID.text},args={$args.st})
	;

assignment
        :       ^(ASSIGN ID expr) -> assign(name={$ID.text},value={$expr.st})
        ;

boolExpr
	:	^(o=CMPOP e1=expr e2=expr) -> expr(e1={$e1.st},e2={$e2.st},op={$o.text})
	;

expr
	:	^(EXPR '+' e=expr e2=expr) -> expr(e1={$e.st},e2={$e2.st},op={"+"})
	|	^(EXPR '-' e=expr e2=expr) -> expr(e1={$e.st},e2={$e2.st},op={"-"})
	|	^(EXPR '*' e=expr e2=expr) -> expr(e1={$e.st},e2={$e2.st},op={"*"})
	|	^(EXPR '/' e=expr e2=expr) -> expr(e1={$e.st},e2={$e2.st},op={"/"})
	|	^(EXPR atom) -> {$atom.st}
	;


atom	:       INT		-> int_constant(val={$INT.text})
        |       FLOAT 		-> float_constant(val={$FLOAT.text})
        |       STRING		-> string_constant(text={$STRING.text})
        |       ID		-> ident(name={$ID.text})
        ;
