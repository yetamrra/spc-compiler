tree grammar SLJavaEmitter;

options {
    tokenVocab=SpokenLang;
    ASTLabelType=SLTreeNode;
    output=template;
}

@header {
	package org.bxg.spokencompiler;
}

program [String name,Scope symbols]
	:	f+=function+ -> program(fList={$f},name={$name}) ;

function
	:	^(FUNCTION ID argList? functionBody)	-> function(name={$ID.text},type={((FunctionSym)$ID.symbol).returnType},params={$argList.st},body={$functionBody.st})
	//|	^(FUNCTION ID functionBody)		-> function(name={$ID.text},body={$functionBody.st})
	;

argList
	:	^(ARG_LIST formal+=formalArg+ ) -> arglist(args={$formal})
	;

formalArg
	:	ID	-> formal_arg(type={$ID.symbol.varType},name={$ID.text})
	;

functionBody
        :       ^(BLOCK el+=stmt+) -> block(body={$el})
        ;

stmt    
	:       assignment -> {$assignment.st}
	|	printStmt -> {$printStmt.st}
	|	whileStmt -> {$whileStmt.st}
	|	callStmt -> {$callStmt.st}
	|	returnStmt -> {$returnStmt.st}
	|	emptyStmt -> {$emptyStmt.st}
	|	ifStmt -> {$ifStmt.st}
	;

whileStmt
	:	^(WHILE boolExpr functionBody)
	->	while(guard={$boolExpr.st},body={$functionBody.st})
	;
	
printStmt
	:	^(PRINT expr) 		-> printOut(string={$expr.st})
	|	PRINTLN 		-> printOut(string={"\"\\n\""})
	;

callStmt
	:	^(CALL ID args+=expr*)
	->	funcStmt(func={$ID.text},args={$args})
	;

returnStmt
	:	^(RETURN expr)
	->	return(expr={$expr.st})
	;

ifStmt
	:	^(IF boolExpr t=functionBody f=functionBody)
	->	ifStmt(cond={$boolExpr.st},trueBlock={$t.st},falseBlock={$f.st})
	;

assignment
        :       ^(ASSIGN ID expr) 	-> {$ID.symbol != null && $ID.symbol.definition == $ID}? assign(type={$ID.symbol.varType},name={$ID.text},value={$expr.st})
					-> assign(name={$ID.text},value={$expr.st})
        ;

emptyStmt
	:	NOTHING
	->	//{%{"/* nothing */"}}	
		emptyStmt(junk={""})
	;

boolExpr
	:	^(o=CMPOP e1=expr e2=expr)
	-> 	expr(e1={$e1.st},e2={$e2.st},op={$o.text})
	;

expr
	:	^(EXPR '+' e=expr e2=expr) -> expr(e1={$e.st},e2={$e2.st},op={"+"})
	|	^(EXPR '-' e=expr e2=expr) -> expr(e1={$e.st},e2={$e2.st},op={"-"})
	|	^(EXPR '*' e=expr e2=expr) -> expr(e1={$e.st},e2={$e2.st},op={"*"})
	|	^(EXPR '/' e=expr e2=expr) -> expr(e1={$e.st},e2={$e2.st},op={"/"})
	|	^(EXPR atom) -> {$atom.st}
	|	^(EXPR callExpr) -> {$callExpr.st}
	;

callExpr
	:	^(CALL ID args+=expr*)
	->	funcCall(func={$ID.text},args={$args})
	;


atom	:       INT		-> int_constant(val={$INT.text})
        |       FLOAT 		-> float_constant(val={$FLOAT.text})
        |       STRING		-> string_constant(text={$STRING.text})
        |       ID 		-> ident(name={$ID.text})
        ;
