tree grammar SLJavaEmitter;

options {
    tokenVocab=SpokenLang;
    ASTLabelType=CommonTree;
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
        :       ^(BLOCK el+=expr+) -> block(body={$el})
        ;

expr    :       assignment -> {$assignment.st}
        ;

assignment
        :       ^(ASSIGN ID rvalue) { $VarScope::symbols.add($ID.text); } -> assign(name={$ID.text},value={$rvalue.st})
        ;

rvalue  :       INT		-> int_constant(val={$INT.text})
        |       FLOAT 		-> float_constant(val={$FLOAT.text})
        |       STRING		-> string_constant(text={$STRING.text})
        |       ID		-> ident(name={$ID.text})
        ;
