tree grammar SLJavaEmitter;

options {
    tokenVocab=SpokenLang;
    ASTLabelType=CommonTree;
    output=template;
}

program: f+=function* -> program(fList={$f},name={"hello"}) ;

function: ^(FUNCTION ID)
    -> function(name={$ID.text})
    ;
