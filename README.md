spc-compiler
============

This is the compiler for the spoken language in Benjamin M. Gordon's PhD
dissertation.  The files in the tests directory exhibit all the syntax, but for
now there isn't any other complete description outside the dissertation.

After cloning the project, you first need to download ANTLR 3.5.2 from
http://antlr3.org/ and put the antlr-3.5.2-complete.jar in the lib directory.

To build the project, you currently need both Eclipse and make.  Eclipse will
automatically run make whenever you touch one of the .g files, and the Makefile
takes care of running ANTLR.  The first time you open the project, Eclipse
won't see the generated files, so you may have to build it and refresh the package
explorer a couple of times to get it to be happy.  After that, it should 
rebuild without further messing around.

The top-level spc script is a wrapper around the Eclipse output in bin that you
can run to compile a .spk file.

You can also use the spc.jardesc to export a working self-contained spc.jar.  You
can run spc.jar directly to compile files, or link to it to embed the compiler
into other projects.  The related spc-plugin project uses this latter idea.
