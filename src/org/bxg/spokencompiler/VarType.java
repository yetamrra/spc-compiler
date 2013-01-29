package org.bxg.spokencompiler;

enum VarType
{
    UNKNOWN
    , INT
    , FLOAT
    , STRING
    , FUNCTION
    , VOID
    , BOOLEAN
    , ARRAY
    ;

    public VarType subType;
    
    public String toString()
    {
        switch ( this ) {
            case UNKNOWN:
                return super.toString();

            case ARRAY:
            	return "array of " + subType.toString();
            	
            default:
                return super.toString().toLowerCase();
        }
    }

    public String getJavaType()
    {
        switch ( this ) {
            case UNKNOWN:
                return super.toString();

            case STRING:
                return "java.lang.String";

            case ARRAY:
            	return subType.getJavaType() + "[]";
            	
            default:
                return super.toString().toLowerCase();
        }
    }
};
