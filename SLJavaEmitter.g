tree grammar SLJavaEmitter;

options {
    tokenVocab=SpokenLang;
    ASTLabelType=CommonTree;
    output=template;
}

program [String name]
	:	f+=function+ { System.out.println("func"); } -> program(fList={$f},name={$name}) ;

function
	:	^(FUNCTION ID argList functionBody) { System.out.println("Here"); } -> function(name={$ID.text},body={$functionBody.st})
	|	^(FUNCTION ID functionBody) { System.out.println("Here2"); } -> function(name={$ID.text},body={$functionBody.st})
	;

argList
	:	^(ARG_LIST args+=ID+)
	;

functionBody
        :       ^(BLOCK el+=expr+)
        ;

expr    :       assignment
        ;

assignment
        :       ^(ASSIGN ID rvalue) -> assign(name={$ID.text},value={$rvalue.st})
        ;

rvalue  :       INT
        |       FLOAT 
        |       STRING 
        |       ID
        ;
