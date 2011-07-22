public class hello
{
    static class SpokenProgram
    {
        void f()
        {
            // Code goes here
            System.out.println("Entered function f");
        }
        void main()
        {
            // Code goes here
            System.out.println("Entered function main");
        }

    }

    public static void main( String args[] ) throws Exception
    {
        SpokenProgram p = new SpokenProgram();
        p.main();
    }
}