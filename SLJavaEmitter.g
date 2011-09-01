tree grammar SLJavaEmitter;

options {
    tokenVocab=SpokenLang;
    ASTLabelType=CommonTree;
    output=template;
}

program [String name]
	:	f+=function+ { System.out.println("func"); } -> program(fList={$f},name={$name}) ;

function
	:	^(FUNCTION ID argList functionBody)	-> function(name={$ID.text},args={$argList.st},body={$functionBody.st})
	|	^(FUNCTION ID functionBody)		-> function(name={$ID.text},body={$functionBody.st})
	;

argList
	:	^(ARG_LIST args+=ID+) -> arglist(args={$args})
	;

functionBody
        :       ^(BLOCK el+=expr+) -> block(body={$el})
        ;

expr    :       assignment -> {$assignment.st}
        ;

assignment
        :       ^(ASSIGN ID rvalue) -> assign(name={$ID.text},value={$rvalue.st})
        ;

rvalue  :       INT		-> int_constant(val={$INT.text})
        |       FLOAT 		-> float_constant(val={$FLOAT.text})
        |       STRING		-> string_constant(text={$STRING.text})
        |       ID		-> ident(name={$ID.text})
        ;
