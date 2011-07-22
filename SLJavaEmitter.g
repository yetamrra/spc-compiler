tree grammar SLJavaEmitter;

options {
    tokenVocab=SpokenLang;
    ASTLabelType=CommonTree;
    output=template;
}

program [String name]
	:	f+=function* -> program(fList={$f},name={$name}) ;

function
	:	^(FUNCTION ID ARG_LIST? functionBody) -> function(name={$ID.text},body={$functionBody.st})
	//|	^(FUNCTION ID  functionBody) -> function(name={$ID.text},args="",body={$functionBody})
	;

functionBody
        :       expr+
        ;

expr    :       assignment
        ;

assignment
        :       ^(ASSIGN ID rvalue) -> assign(name={$ID.text},value={$rvalue.st})
        ;

rvalue  :       INT | FLOAT | STRING | ID;
