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
        if ( this == UNKNOWN ) {
            return super.toString();
        } else {
            return super.toString().toLowerCase();
        }
    }
};
