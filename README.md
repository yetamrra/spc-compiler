spc-compiler
============

This is the compiler for the spoken language in Benjamin M. Gordon's PhD dissertation.  The files in the tests directory exhibit all the syntax, but for now there isn't any other complete description outside the dissertation.

After cloning the project, you first need to download ANTLR 3.5.2 from http://antlr3.org/ and put the antlr-3.5.2-complete.jar in the lib directory.

To build the project, you currently need both Eclipse and make.  First, run
  make -C src
to generate the ANTLR output.  Then open the project in Eclipse and build it.

The top-level spc script is a wrapper around the Eclipse output that you can run to compile a .spk file.
