enum VarType
{
    UNKNOWN
    , INT
    , FLOAT
    , STRING
    , FUNCTION
    ;

    public String toString()
    {
        switch ( this ) {
            case UNKNOWN:
                return super.toString();

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

            default:
                return super.toString().toLowerCase();
        }
    }
};
