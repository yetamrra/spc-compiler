grammar SpokenLang;

options {
  // We're going to output an AST.
  output = AST;
  
  // Java type of the tree
  ASTLabelType = SLTreeNode;
}
// These are imaginary tokens that will serve as parent nodes
// for grouping other tokens in our AST.
tokens {
	FUNCTION;
	ARG_LIST;
    BLOCK;
	EXPR;
	PRINTLN;
}

@header {
	package org.bxg.spokencompiler;
}

@lexer::header {
	package org.bxg.spokencompiler;
}

@members {
	Scope currentScope;
}

IF : 'if' ;

THEN : 'then' ;

ELSE : 'else' ;

IF_END : END WS IF ;

NOTHING : 'nothing' ;

PRINT : 'print' ;

WHILE : 'while' ;

DO : 'do' ;

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

CALL	:	'call' ;
CALLING	:	'calling' ;

WITH	:	'with' ;

fragment
NEW	:	'new' ;

fragment
LINE	:	'line' ;

NEW_LINE :	NEW WS LINE ;

fragment
END 	:	'end' ;


WHILE_END
	:	END WS WHILE ;

FUNC_END 
	:	END WS FUNCTION ;

fragment
THE	:	'the' ;

fragment
RESULT	:	'result';

fragment
OF	:	'of';

RESULT_OF
	:	THE WS RESULT WS OF ;

AND 	:	'and' ;

RETURN	:	'return';

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

CMPOP
	:	'<'
	|	'>'
	|	'='
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

stmt 	
	:	printStmt
	|	assignment
	|	whileStmt
	|	callStmt
	|	returnStmt
	|	emptyStmt
	|	ifStmt
	;

assignment 
	:	ASSIGN ID TO expr -> ^(ASSIGN ID expr)
	|	ASSIGN ID TO callExpr -> ^(ASSIGN ID callExpr)
	;

printStmt
	:	PRINT expr -> ^(PRINT expr)
    |   PRINT callExpr -> ^(PRINT callExpr)
	|	NEW_LINE -> ^(PRINTLN)
	;

whileStmt
	:	WHILE boolExpr DO functionBody WHILE_END
	->	^(WHILE boolExpr functionBody)
	;

callStmt
	:	CALL ID (WITH expr (AND expr)*)?
	->	^(CALL ID expr*)
	;

callingStmt
	:	CALLING ID (WITH expr (AND expr)*)?
	->	^(CALL ID expr*)
	;

returnStmt
	:	RETURN expr ->	^(RETURN expr)
	|	RETURN callExpr ->	^(RETURN callExpr)
	;

emptyStmt
	:	NOTHING
	->	NOTHING
	;

ifStmt
	:	IF boolExpr THEN functionBody ELSE functionBody IF_END
	->	^(IF boolExpr functionBody functionBody)
	;

boolExpr
	:	expr CMPOP expr
	->  ^(CMPOP expr expr)
	;

expr
	:	multExpr '+' multExpr
	->	^(EXPR '+' multExpr multExpr)
	|	multExpr '-' multExpr
	->	^(EXPR '-' multExpr multExpr)
	|	multExpr
	->	multExpr
	;

multExpr
	:	atom '*' atom
	->	^(EXPR '*' ^(EXPR atom) ^(EXPR atom))
	|	atom '/' atom
	->	^(EXPR '/' ^(EXPR atom) ^(EXPR atom))
	|	atom
	->	^(EXPR atom)
	;

atom
	:	INT | FLOAT | STRING | ID;

callExpr
	:	RESULT_OF callingStmt
	->	^(EXPR callingStmt)
	;

functionDefBare 
	:	FUNC_DEF ID NO_ARGS AS functionBody FUNC_END { System.out.println("Function " + $ID.text + "()"); }
	->	^(FUNCTION ID functionBody)
	;
	
functionDefArgs
	:	FUNC_DEF ID WITH_ARGS argList AS functionBody FUNC_END { System.out.println("Function " + $ID.text + "(" + $argList.text + ")"); }
	->	^(FUNCTION ID argList functionBody)
	;
	
functionBody 
	:	stmt+ -> ^(BLOCK stmt+)
	;
	
argList :	ID ( AND ID )* -> ^(ARG_LIST ID+)
	;
