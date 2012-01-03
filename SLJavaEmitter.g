tree grammar SLJavaEmitter;

options {
    tokenVocab=SpokenLang;
    ASTLabelType=SLTreeNode;
    output=template;
}

scope VarScope {
    SymbolTable symbols;
    String name;
}

program [String name]
scope VarScope;
@init {
    // Set up the global scope
    $VarScope::symbols = new SymbolTable();
    $VarScope::name = "global";
}
@after {
    System.out.println( "Global symbols: " + $VarScope::symbols );
}
	:	f+=function+ { System.out.println("func"); } -> program(fList={$f},name={$name}) ;

function
scope VarScope;
@init {
    // Set up the global scope
    $VarScope::symbols = new SymbolTable();
}
@after {
    System.out.println( "Symbols from " + $VarScope::name + ": " + $VarScope::symbols );
}
	:	^(FUNCTION ID argList functionBody)	{ $VarScope::name = $ID.text; } -> function(name={$ID.text},params={$argList.st},body={$functionBody.st},locals={$VarScope::symbols})
	|	^(FUNCTION ID functionBody)		{ $VarScope::name = $ID.text; } -> function(name={$ID.text},body={$functionBody.st},locals={$VarScope::symbols})
	;

argList
scope VarScope;
@init {
    $VarScope::symbols = new SymbolTable();
}
@after {
    System.out.println( "Symbols from function args: " + $VarScope::symbols );
}
	:	^(ARG_LIST args+=(ID { $VarScope::symbols.add($ID.text); })+ ) -> arglist(args={$VarScope::symbols.getSt()})
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
        :       ^(ASSIGN ID expr) { $VarScope::symbols.add($ID.text); } -> assign(name={$ID.text},value={$expr.st})
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
