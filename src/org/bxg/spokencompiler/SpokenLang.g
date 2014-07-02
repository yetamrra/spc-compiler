/*
 * Copyright 2011-2014 Benjamin M. Gordon
 * 
 * This file is part of the spoken language compiler.
 *
 * The spoken language compiler is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The spoken language compiler is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the spoken language compiler.  If not, see <http://www.gnu.org/licenses/>.
 */

grammar SpokenLang;

options {
  // We're going to output an AST.
  output = AST;
  
  // Java type of the tree
  ASTLabelType = SLTreeNode;
  
  backtrack = true;
  
}
// These are imaginary tokens that will serve as parent nodes
// for grouping other tokens in our AST.
tokens {
	FUNCTION;
	ARG_LIST;
    BLOCK;
	EXPR;
	PRINTLN;
	ARRAYREF;
	PRINTSPACE;
}

@header {
	package org.bxg.spokencompiler;
}

@lexer::header {
	package org.bxg.spokencompiler;
}

@lexer::members {
	String fixString( String str )
	{
		String ret = str.replace( "\\", "\\\\" );
		ret = '"' + ret + '"';
		return ret;
	}
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

READ  : 'read' ;

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

OF	:	'of' ;

RESULT_OF
	:	THE WS RESULT WS OF ;

AND 	:	'and' ;

NOT		:	'not' ;

OR		:	'or' ;

boolOp	:	AND
		|	OR
		;
		
RETURN	:	'return';

ELEMENT	:	'element' ;

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

THE_STRING
	:	THE WS 'string'
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

WORDS
	:	THE_STRING WS { StringBuilder s = new StringBuilder(); }
	    ( options {greedy=false;} : w=. {s.append((char)$w);} )* '\n'
	    { setText(fixString(s.toString())); }
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
	|   readStmt
	|	assignment
	|	whileStmt
	|	callStmt
	|	returnStmt
	|	emptyStmt
	|	ifStmt
	;

assignment 
	:	ASSIGN arrayRef TO expr -> ^(ASSIGN arrayRef expr)
	|	ASSIGN arrayRef TO callExpr -> ^(ASSIGN arrayRef callExpr)
	|	ASSIGN ID TO expr -> ^(ASSIGN ID expr)
	|	ASSIGN ID TO callExpr -> ^(ASSIGN ID callExpr)
	;

printStmt
	:	PRINT expr -> ^(PRINT expr)
	|	PRINT 'space' -> ^(PRINTSPACE)
    |   PRINT callExpr -> ^(PRINT callExpr)
	|	NEW_LINE -> ^(PRINTLN)
	;

readStmt
	:	READ ID -> ^(READ ID)
	|	READ arrayRef -> ^(READ arrayRef)
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
	:	primBool boolOp primBool -> ^(boolOp primBool primBool)
	|	NOT boolExpr			 -> ^(NOT boolExpr)
	|	primBool 				 -> primBool
	;

primBool
	:	expr CMPOP expr	->  ^(CMPOP expr expr)
	;
	
expr
	:	multExpr '+' multExpr 	->	^(EXPR '+' multExpr multExpr)
	|	multExpr '-' multExpr 	->	^(EXPR '-' multExpr multExpr)
	|	multExpr				->	multExpr
	;

multExpr
	:	varRef '*' varRef
	->	^(EXPR '*' ^(EXPR varRef) ^(EXPR varRef))
	|	varRef '/' varRef
	->	^(EXPR '/' ^(EXPR varRef) ^(EXPR varRef))
	|	varRef
	->	^(EXPR varRef)
	;

varRef
	:	atom
	|	arrayRef
	;
	
atom
	:	INT | FLOAT | WORDS | STRING | ID;

arrayRef
	:	ELEMENT atom OF ID
	->	^(ARRAYREF atom ID)
	;
	
callExpr
	:	RESULT_OF callingStmt
	->	^(EXPR callingStmt)
	;

functionDefBare 
	:	FUNC_DEF ID NO_ARGS AS functionBody FUNC_END { /*System.out.println("Function " + $ID.text + "()");*/ }
	->	^(FUNCTION ID functionBody)
	;
	
functionDefArgs
	:	FUNC_DEF ID WITH_ARGS argList AS functionBody FUNC_END { /*System.out.println("Function " + $ID.text + "(" + $argList.text + ")");*/ }
	->	^(FUNCTION ID argList functionBody)
	;
	
functionBody 
	:	stmt+ -> ^(BLOCK stmt+)
	;
	
argList :	ID ( AND ID )* -> ^(ARG_LIST ID+)
	;
