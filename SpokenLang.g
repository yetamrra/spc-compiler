grammar SpokenLang;

options {
  // We're going to output an AST.
  output = AST;
  
  // Java type of the tree
  ASTLabelType = CommonTree;
}
// These are imaginary tokens that will serve as parent nodes
// for grouping other tokens in our AST.
tokens {
	FUNCTION;
	ARG_LIST;
        BLOCK;
}

@members {
    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println( "Usage: SpokenLangParser file.spk" );
            return;
        }

        SpokenLangLexer lex = new SpokenLangLexer(new ANTLRFileStream(args[0]));
       	CommonTokenStream tokens = new CommonTokenStream(lex);

        SpokenLangParser parser = new SpokenLangParser(tokens);

        try {
            parser.program();
        } catch (RecognitionException e)  {
            e.printStackTrace();
        }
    }
}

ASSIGN 	:	'set' ;
TO 	:	'to' ;

DEFINE 	:	'define' ;

FUNCTION 
	:	'function' ;

FUNC_DEF 
	:	DEFINE WS FUNCTION ;
	
fragment
TAKING	:	'taking' ;

fragment
NO 	:	'no' ;

fragment
ARGUMENTS
	:	'arguments' ;
	
NO_ARGS :	TAKING WS NO WS ARGUMENTS ;
WITH_ARGS 
	:	TAKING WS ARGUMENTS ;
	
AS	:	'as' ;

fragment
END 	:	'end' ;

FUNC_END 
	:	END WS FUNCTION ;
	
AND 	:	'and' ;

ID  :	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*
    ;

INT :	'0'..'9'+
    ;

FLOAT
    :   ('0'..'9')+ '.' ('0'..'9')* EXPONENT?
    |   '.' ('0'..'9')+ EXPONENT?
    |   ('0'..'9')+ EXPONENT
    ;

WS  :   ( ' '
        | '\t'
        | '\r'
        | '\n'
        ) {$channel=HIDDEN;}
    ;

STRING
    :  '"' ( ESC_SEQ | ~('\\'|'"') )* '"'
    ;

fragment
EXPONENT : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;

fragment
HEX_DIGIT : ('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
ESC_SEQ
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UNICODE_ESC
    |   OCTAL_ESC
    ;

fragment
OCTAL_ESC
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UNICODE_ESC
    :   '\\' 'u' HEX_DIGIT HEX_DIGIT HEX_DIGIT HEX_DIGIT
    ;

/*******************************************************
 ** End of Lexer Grammar 
 *******************************************************/
 
 
program
	:	functionList EOF! ;

functionList 
	:	functionDefBare functionList?
	|	functionDefArgs functionList?
	;

expr 	:	assignment
	;

assignment 
	:	ASSIGN ID TO rvalue -> ^(ASSIGN ID rvalue)
	;

rvalue 	:	INT | FLOAT | STRING | ID;

functionDefBare 
	:	FUNC_DEF ID NO_ARGS AS functionBody FUNC_END { System.out.println("Function " + $ID.text + "()"); }
	->	^(FUNCTION ID functionBody)
	;
	
functionDefArgs
	:	FUNC_DEF ID WITH_ARGS argList AS functionBody FUNC_END { System.out.println("Function " + $ID.text + "(" + $argList.text + ")"); }
	->	^(FUNCTION ID argList functionBody)
	;
	
functionBody 
	:	expr+ -> ^(BLOCK expr+)
	;
	
argList :	ID ( AND ID )* -> ^(ARG_LIST ID+)
	;
