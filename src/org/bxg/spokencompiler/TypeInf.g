/*
 * Copyright 2012-2014 Benjamin M. Gordon
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

tree grammar TypeInf;
options {
  tokenVocab = SpokenLang;
  ASTLabelType = SLTreeNode;
  filter = true;
}

@header {
	package org.bxg.spokencompiler;

    import java.util.Set;
    import java.util.HashSet;
    import java.util.Iterator;
}

@members {
    public Scope currentScope;
	public Set<VarConstraint> constraints = new HashSet();
    public SLTreeNode currentFunction;

    VarType matchTypes( VarType knownType, VarType matchType, SLTreeNode node )
    {
        if ( knownType == VarType.UNKNOWN ) {
            // If the LHS is unknown then the type it should be
            // set to is the RHS
            return matchType;
        } else {
            // The LHS has a known type, so make sure they match
            if ( matchType != VarType.UNKNOWN && knownType != matchType ) {
                throw new CompileException( "Incompatible types " + knownType + " and " + matchType + " for " + node.getText() + " at line " + node.getLine() );
            } else {
                return knownType;
            }
        }
    }

    void constrainType( SLTreeNode node, VarType vType, boolean isArray )
    {
        if ( node.symbol == null ) {
            throw new CompileException( "Unresolved variable " + node.getText() + " at line " + node.getLine() );
        } else if ( vType == VarType.UNKNOWN || vType == null ) {
            return;
        } else if ( node.symbol.varType == VarType.FUNCTION ) {
            // Setting the return type of a function.  Use the returnType instead of
            // varType
            FunctionSym f = (FunctionSym)node.symbol;
            VarType t = matchTypes( f.returnType, vType, node );
            if ( t != VarType.UNKNOWN ) {
                f.returnType = t;
				//System.out.println( "Constraint: typeof(" + node.getText() + "()) = " + vType );
                // FIXME: add constraint
            }
        } else {
            // Try to set the variable type
            SymEntry s = node.symbol;
            VarType t = matchTypes( s.varType, vType, node );
            if ( t != VarType.UNKNOWN ) {
                s.varType = t;
                // FIXME: figure out how to handle this properly
                /*
                if ( s.isArray && !isArray ) {
					throw new CompileException( "Attempting to assign scalar to array `" + node.getText() + "` at line " + node.getLine() );
				} else if ( !s.isArray && isArray ) {
					throw new CompileException( "Attempting to assign array to scalar `" + node.getText() + "` at line " + node.getLine() );
				}*/
                //System.out.println( "Constraint: typeof(" + node.getText() + ") = " + vType );
                // FIXME: add constraint
            }
        }
    }

    void constrainTypeList( List<SLTreeNode> nodes, VarType vType )
    {
        for ( SLTreeNode n: nodes ) {
            constrainType( n, vType, false );
        }
    }

    void addConstraintList( SymEntry lhs, List<SLTreeNode> rhs )
    {
        for ( SLTreeNode s: rhs ) {
            addConstraint( lhs, s.symbol );
        }
    }

    void addConstraint( SymEntry lhs, SymEntry rhs )
    {
        VarConstraint v = new VarConstraint(lhs,rhs);
        constraints.add( v  );
        //System.out.println( "New constraint: " + v );
    }

    void processConstraints( boolean isFinal )
    {
        //System.out.println( "Processing constraints" + (isFinal ? " at the end" : "") + ": " + constraints );
        while ( constraints.size() > 0 ) {
            int s = constraints.size();
            Iterator i = constraints.iterator();
            while ( i.hasNext() ) {
                VarConstraint v = (VarConstraint)i.next();
                if ( unifyTypes( v.v1, v.v2 ) ) {
                    i.remove();
                }
            }
            if ( s == constraints.size() ) {
                // Didn't eliminate any constraints.
                break;
            }
        }
        if ( isFinal ) {
            // For anything left unsolved, functions must be void
            // and variables must be Object.
            Iterator i = constraints.iterator();
            while ( i.hasNext() ) {
                VarConstraint v = (VarConstraint)i.next();
                if ( v.v1.varType == VarType.FUNCTION ) {
                    //assert ((FunctionSym)v.v1).returnType == VarType.UKNOWN; 
                    ((FunctionSym)v.v1).returnType = VarType.VOID;
                }
                if ( v.v2.varType == VarType.FUNCTION ) {
                    //assert ((FunctionSym)v.v2).returnType == VarType.UKNOWN; 
                    ((FunctionSym)v.v2).returnType = VarType.VOID;
                }
            }
        }
    }

    boolean unifyTypes( SymEntry v1, SymEntry v2 )
    {
        VarType t1 = (v1.varType == VarType.FUNCTION) ? ((FunctionSym)v1).returnType : v1.varType;
        VarType t2 = (v2.varType == VarType.FUNCTION) ? ((FunctionSym)v2).returnType : v2.varType;

        if ( t1 == VarType.UNKNOWN ) {
            if ( t2 == VarType.UNKNOWN ) {
                return false;
            } else {
                if ( v1.varType == VarType.FUNCTION ) {
                    ((FunctionSym)v1).returnType = t2;
                } else {
                    v1.varType = t2;
                }
                //System.out.println( "Solved constraint: typeof(" + v1.scope.getScopeName() + "::" + v1.name + ") = " + t2 );
                return true;
            }
        } else {
            if ( t2 == VarType.UNKNOWN ) {
                if ( v2.varType == VarType.FUNCTION ) {
                    ((FunctionSym)v2).returnType = t1;
                } else {
                    v2.varType = t1;
                }
                //System.out.println( "Solved constraint: typeof(" + v2.scope.getScopeName() + "::" + v2.name + ") = " + t1 );
                return true;
            } else {
                if ( t1 != t2 ) {
                    throw new CompileException( "Types of " + v1 + " and " + v2 + " are not compatible." );
                } else {
                    /*System.out.println( "Solved constraint: typeof(" + 
                                        v1.scope.getScopeName() + "::" + v1.name + ") = typeof(" +
                                        v2.scope.getScopeName() + "::" + v2.name + ") => both " + t1 );*/ 
                    return true;
                }
            }
        }
    }

    VarType getFuncType( SLTreeNode node )
    {
    	FunctionSym fun = getFunction( node );
        return fun.returnType;
    }
    
    FunctionSym getFunction( SLTreeNode node )
    {
    	// Make sure node represents a function and then
        // return its symbol.
        if ( node.symbol == null ) {
            // Try to resolve the function.  It would have been previously skipped
            // if it was a forward reference.
            SymEntry var = currentFunction.scope.resolve( node.getText(), false );
            if ( var == null ) {
                throw new CompileException( "Unresolved function " + node.getText() + " at line " + node.getLine() );
            } else {
                node.symbol = var;
            }
        }
        
        if ( node.symbol.varType == VarType.FUNCTION ) {
        	return (FunctionSym)node.symbol;
        } else {
        	throw new CompileException( "Can't call non-function symbol " + node.getText() + " at line " + node.getLine() );
        }
    }
    
}

// Topdown and bottomup tell ANTLR which rules
// to process as it goes down and then up the tree.
topdown
    :   enterFunction
    ;

bottomup
    :   exprRoot
    |   boolExpr
	|	assignment
    |   returnStmt
    |   callStmt
    |   exitFunction
    ;

assignment
	:	^(ASSIGN ID rhs=exprRoot) 
        {
            constrainType( $ID, $rhs.type, false );
            addConstraintList( $ID.symbol, $rhs.vars );
            if ( $ID.evalType != VarType.UNKNOWN ) {
                constrainTypeList( $rhs.vars, $ID.evalType );
            }
        }
	|	^(ASSIGN ^(ARRAYREF idx=atom ID) rhs=exprRoot) 
        {
            constrainType( $ID, $rhs.type, true );
            addConstraintList( $ID.symbol, $rhs.vars );
            constrainTypeList( $idx.vars, VarType.INT );
            if ( $ID.evalType != VarType.UNKNOWN ) {
                constrainTypeList( $rhs.vars, $ID.evalType );
            }
        }
	;

returnStmt
    :   ^(RETURN rhs=exprRoot)
        {
            constrainType( currentFunction, $rhs.type, false );
            addConstraintList( currentFunction.symbol, $rhs.vars );
        }
    ;

callStmt returns [VarType type, List<SLTreeNode> vars]
    :   ^(CALL ID args+=exprRoot*)
        {
            $type = $CALL.evalType = getFuncType($ID);
            $vars = new ArrayList();
            $vars.add( $ID );
            
            if ( $args != null && $args.size() > 0 ) {
	            FunctionSym fun = getFunction( $ID );
	            if ( $args.size() != fun.arguments.size() ) {
	            	throw new CompileException( "Called function " + $ID.text + " with " + $args.size() + " arguments when " + fun.arguments.size() + " are needed at line " + $ID.line );
	            }
	            
	            for ( int i=0; i<$args.size(); i++ ) {
	            	exprRoot_return arg = (exprRoot_return)$args.get( i );
	            	SymEntry formalArg = fun.arguments.get( i );
	            	addConstraintList( formalArg, arg.vars );
	            }
	        }
        }
    ;

exprRoot returns [VarType type, List<SLTreeNode> vars]
    @after { /*System.out.println( "typeof(" + $exprRoot.text + ") = " + $type );*/ }
	:	^(EXPR expr)
        {
            $type = $EXPR.evalType = $expr.type;
            $vars = $expr.vars;
        }
	;

boolExpr returns [VarType type, List<SLTreeNode> vars]
    @after { /*System.out.println( "typeof(" + $boolExpr.text + ") = " + $type );*/ }
	:	^(CMPOP e1=exprRoot e2=exprRoot)
        {
            $type = $CMPOP.evalType = VarType.BOOLEAN;
            if ( $CMPOP.text.equals("<") ||
                 $CMPOP.text.equals("<=") ||
                 $CMPOP.text.equals(">") ||
                 $CMPOP.text.equals(">=")
               )
            {
                constrainTypeList( $e1.vars, VarType.INT );
                constrainTypeList( $e2.vars, VarType.INT );
            } else {
                // FIXME: deal with == and !=
            }
            $vars = null;
            for ( SLTreeNode n: $e1.vars ) {
                addConstraintList( n.symbol, $e2.vars );
            }
            for ( SLTreeNode n: $e2.vars ) {
                addConstraintList( n.symbol, $e1.vars );
            }
        }
	;

expr returns [VarType type, List<SLTreeNode> vars]
	: atom { $type = $atom.type; $vars = $atom.vars; }
    | callStmt { $type = $callStmt.type; $vars = $callStmt.vars; }
    | arrayRef { $type = $arrayRef.type; $vars = $arrayRef.vars; }
	;
 
enterFunction
    :   ^(FUNCTION ID .*)
        {
            currentFunction = $ID;
            if ( currentFunction.symbol == null ) {
                throw new CompileException( "Unresolved function " + $ID.text + " entered at line " + $ID.line );
            }
        }
    ;

exitFunction
    :   FUNCTION
        {
            processConstraints( false );

            // If the function's type is unknown, add a constraint of
            // setting it to itself.  This allows us to later detect
            // that it needs to become void.
            if ( ((FunctionSym)currentFunction.symbol).returnType == VarType.UNKNOWN ) {
               addConstraint( currentFunction.symbol, currentFunction.symbol );
            }
        }
    ;

atom returns [VarType type, List<SLTreeNode> vars]
    @init { $vars = new ArrayList(); }
    @after { /*System.out.println( "Vars in " + $start.toStringTree() + ": " + $vars );*/ }
	:	INT 	{ $type = VarType.INT; }
	|	FLOAT 	{ $type = VarType.FLOAT; }
	|	STRING 	{ $type = VarType.STRING; }
	|	WORDS	{ $type = VarType.STRING; }
	|	ID		
		{ 
            //System.out.println( "Found ID " + $ID.text );
			if ( $ID.symbol == null ) {
				SymEntry s = $ID.scope.resolve( $ID.text, false );
				if ( s == null ) {
					throw new CompileException( "Unresolved symbol `" + $ID.text + "` encountered at line " + $ID.line );
				}
				$ID.symbol = s;
			}

			$type = $ID.symbol.varType; 
            $vars.add( $ID );
		}
	|	binaryOp
        {
            $type = $binaryOp.type;
            $vars = $binaryOp.vars;
        }
	;

arrayRef returns [VarType type, List<SLTreeNode> vars]
	@init { $vars = new ArrayList(); }
	@after { /*System.out.println( "Vars in " + $start.toStringTree() + ": " + $vars );*/ }
	:	^(ARRAYREF atom ID)
		{
			//System.out.println( "Found array ID " + $ID.text );
			if ( $ID.symbol == null ) {
				SymEntry s = $ID.scope.resolve( $ID.text, false );
				if ( s == null ) {
					throw new CompileException( "Unresolved array `" + $ID.text + "` encountered at line " + $ID.line );
				}
				$ID.symbol = s;
				s.isArray = true;
			}
			
			$type = $ID.symbol.varType;
			$vars.add( $ID );
			
			constrainTypeList( $atom.vars, VarType.INT );
		}
	;
	
binaryOp returns [VarType type, List<SLTreeNode> vars]
    @after { $start.evalType = $type; }
	: 	binop a=exprRoot b=exprRoot 
		{ 
			if ( $a.type != VarType.UNKNOWN ) {
				$type = $a.start.evalType;
                constrainTypeList( $b.vars, $type );
                if ( $b.start.symbol != null ) {
                    constrainType( $b.start, $a.start.evalType, false );
                }
		   	} else {
				$type = $b.start.evalType;
                constrainTypeList( $a.vars, $type );
                if ( $a.start.symbol != null ) {
                    constrainType( $a.start, $b.start.evalType, false );
                }
			}
            $vars = $a.vars;
            $vars.addAll( $b.vars );
		}
	;

binop : '+' | '-' | '*' | '/' ;
