// $ANTLR 3.4 TypeInf.g 2012-03-08 22:14:18

import org.antlr.runtime.*;
import org.antlr.runtime.tree.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

@SuppressWarnings({"all", "warnings", "unchecked"})
public class TypeInf extends TreeFilter {
    public static final String[] tokenNames = new String[] {
        "<invalid>", "<EOR>", "<DOWN>", "<UP>", "AND", "ARGUMENTS", "ARG_LIST", "AS", "ASSIGN", "BLOCK", "CALL", "CMPOP", "DEFINE", "DO", "ELSE", "END", "ESC_SEQ", "EXPONENT", "EXPR", "FLOAT", "FUNCTION", "FUNC_DEF", "FUNC_END", "HEX_DIGIT", "ID", "IF", "IF_END", "INT", "LINE", "NEW", "NEW_LINE", "NO", "NOTHING", "NO_ARGS", "OCTAL_ESC", "OF", "PRINT", "PRINTLN", "RESULT", "RESULT_OF", "RETURN", "STRING", "TAKING", "THE", "THEN", "TO", "UNICODE_ESC", "WHILE", "WHILE_END", "WITH", "WITH_ARGS", "WS", "'*'", "'+'", "'-'", "'/'"
    };

    public static final int EOF=-1;
    public static final int T__52=52;
    public static final int T__53=53;
    public static final int T__54=54;
    public static final int T__55=55;
    public static final int AND=4;
    public static final int ARGUMENTS=5;
    public static final int ARG_LIST=6;
    public static final int AS=7;
    public static final int ASSIGN=8;
    public static final int BLOCK=9;
    public static final int CALL=10;
    public static final int CMPOP=11;
    public static final int DEFINE=12;
    public static final int DO=13;
    public static final int ELSE=14;
    public static final int END=15;
    public static final int ESC_SEQ=16;
    public static final int EXPONENT=17;
    public static final int EXPR=18;
    public static final int FLOAT=19;
    public static final int FUNCTION=20;
    public static final int FUNC_DEF=21;
    public static final int FUNC_END=22;
    public static final int HEX_DIGIT=23;
    public static final int ID=24;
    public static final int IF=25;
    public static final int IF_END=26;
    public static final int INT=27;
    public static final int LINE=28;
    public static final int NEW=29;
    public static final int NEW_LINE=30;
    public static final int NO=31;
    public static final int NOTHING=32;
    public static final int NO_ARGS=33;
    public static final int OCTAL_ESC=34;
    public static final int OF=35;
    public static final int PRINT=36;
    public static final int PRINTLN=37;
    public static final int RESULT=38;
    public static final int RESULT_OF=39;
    public static final int RETURN=40;
    public static final int STRING=41;
    public static final int TAKING=42;
    public static final int THE=43;
    public static final int THEN=44;
    public static final int TO=45;
    public static final int UNICODE_ESC=46;
    public static final int WHILE=47;
    public static final int WHILE_END=48;
    public static final int WITH=49;
    public static final int WITH_ARGS=50;
    public static final int WS=51;

    // delegates
    public TreeFilter[] getDelegates() {
        return new TreeFilter[] {};
    }

    // delegators


    public TypeInf(TreeNodeStream input) {
        this(input, new RecognizerSharedState());
    }
    public TypeInf(TreeNodeStream input, RecognizerSharedState state) {
        super(input, state);
    }

    public String[] getTokenNames() { return TypeInf.tokenNames; }
    public String getGrammarFileName() { return "TypeInf.g"; }


        public Scope currentScope;



    // $ANTLR start "bottomup"
    // TypeInf.g:22:1: bottomup : expr ;
    public final void bottomup() throws RecognitionException {
        try {
            // TypeInf.g:23:5: ( expr )
            // TypeInf.g:23:9: expr
            {
            pushFollow(FOLLOW_expr_in_bottomup60);
            expr();

            state._fsp--;
            if (state.failed) return ;

            }

        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }

        finally {
        	// do for sure before leaving
        }
        return ;
    }
    // $ANTLR end "bottomup"


    public static class expr_return extends TreeRuleReturnScope {
        public VarType type;
    };


    // $ANTLR start "expr"
    // TypeInf.g:26:1: expr returns [VarType type] : ^( EXPR atom ) ;
    public final TypeInf.expr_return expr() throws RecognitionException {
        TypeInf.expr_return retval = new TypeInf.expr_return();
        retval.start = input.LT(1);


        VarType atom1 =null;


        try {
            // TypeInf.g:28:2: ( ^( EXPR atom ) )
            // TypeInf.g:28:4: ^( EXPR atom )
            {
            match(input,EXPR,FOLLOW_EXPR_in_expr85); if (state.failed) return retval;

            match(input, Token.DOWN, null); if (state.failed) return retval;
            pushFollow(FOLLOW_atom_in_expr87);
            atom1=atom();

            state._fsp--;
            if (state.failed) return retval;

            match(input, Token.UP, null); if (state.failed) return retval;


            if ( state.backtracking==1 ) { retval.type = atom1; }

            }

            if ( state.backtracking==1 ) { System.out.println( "typeof(" + input.getTokenStream().toString(input.getTreeAdaptor().getTokenStartIndex(retval.start),input.getTreeAdaptor().getTokenStopIndex(retval.start)) + ") = " + retval.type ); }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }

        finally {
        	// do for sure before leaving
        }
        return retval;
    }
    // $ANTLR end "expr"



    // $ANTLR start "atom"
    // TypeInf.g:32:1: atom returns [VarType type] : ( INT | FLOAT | STRING | ID );
    public final VarType atom() throws RecognitionException {
        VarType type = null;


        try {
            // TypeInf.g:33:2: ( INT | FLOAT | STRING | ID )
            int alt1=4;
            switch ( input.LA(1) ) {
            case INT:
                {
                alt1=1;
                }
                break;
            case FLOAT:
                {
                alt1=2;
                }
                break;
            case STRING:
                {
                alt1=3;
                }
                break;
            case ID:
                {
                alt1=4;
                }
                break;
            default:
                if (state.backtracking>0) {state.failed=true; return type;}
                NoViableAltException nvae =
                    new NoViableAltException("", 1, 0, input);

                throw nvae;

            }

            switch (alt1) {
                case 1 :
                    // TypeInf.g:33:4: INT
                    {
                    match(input,INT,FOLLOW_INT_in_atom106); if (state.failed) return type;

                    if ( state.backtracking==1 ) { type = VarType.INT; }

                    }
                    break;
                case 2 :
                    // TypeInf.g:34:4: FLOAT
                    {
                    match(input,FLOAT,FOLLOW_FLOAT_in_atom115); if (state.failed) return type;

                    if ( state.backtracking==1 ) { type = VarType.FLOAT; }

                    }
                    break;
                case 3 :
                    // TypeInf.g:35:4: STRING
                    {
                    match(input,STRING,FOLLOW_STRING_in_atom123); if (state.failed) return type;

                    if ( state.backtracking==1 ) { type = VarType.STRING; }

                    }
                    break;
                case 4 :
                    // TypeInf.g:36:4: ID
                    {
                    match(input,ID,FOLLOW_ID_in_atom131); if (state.failed) return type;

                    if ( state.backtracking==1 ) { type = VarType.UNKNOWN; }

                    }
                    break;

            }
        }
        catch (RecognitionException re) {
            reportError(re);
            recover(input,re);
        }

        finally {
        	// do for sure before leaving
        }
        return type;
    }
    // $ANTLR end "atom"

    // Delegated rules


 

    public static final BitSet FOLLOW_expr_in_bottomup60 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_EXPR_in_expr85 = new BitSet(new long[]{0x0000000000000004L});
    public static final BitSet FOLLOW_atom_in_expr87 = new BitSet(new long[]{0x0000000000000008L});
    public static final BitSet FOLLOW_INT_in_atom106 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_FLOAT_in_atom115 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_STRING_in_atom123 = new BitSet(new long[]{0x0000000000000002L});
    public static final BitSet FOLLOW_ID_in_atom131 = new BitSet(new long[]{0x0000000000000002L});

}