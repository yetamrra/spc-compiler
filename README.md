# spc-compiler

This is the compiler for the spoken language in Benjamin M. Gordon's PhD
dissertation.  The files in the tests directory exhibit all the syntax, but for
now there isn't any other complete description outside the dissertation.

The top-level spc script is a wrapper around the Eclipse output in bin that you
can run to compile a .spk file.

You can also use the spc.jardesc to export a working self-contained spc.jar.
You can run spc.jar directly to compile files, or link to it to embed the
compiler into other projects.  The related spc-plugin project uses this latter
idea.  Note that the default output path assumes that you have the spc-plugin
project added to the same workspace.

You will probably also want to get the
[spc Eclipse plugin](https://github.com/yetamrra/spc-plugin)
in order to actually do spoken programming.

## Prerequisites

*  ANTLR 3.5.2 from [antlr3.org](https://www.antlr3.org/download.html).
*  A recent
   [Eclipse](https://www.eclipse.org/downloads/packages/release/2019-03/r/eclipse-ide-java-developers)
   IDE with the egit and Java plugins.  Fedora's 2018-12 and the upstream
   2019-03 are known to work.  The "Eclipse IDE for Java Developers" edition
   seems to include everything needed.
*  make.  I have only tested with GNU make, but the makefiles aren't very
   fancy, so other versions are likely to work as well.

## Build instructions

1.  Clone the project somewhere, e.g. `~/projects/spc-compiler`
1.  Download
    [antlr-3.5.2-complete.jar](https://www.antlr3.org/download.html)
    from the ANTLR site and put it in the `lib` directory.
1.  Create a new Eclipse workspace, e.g. `~/projects/spc-workspace`
1.  Import `~/projects/spc-compiler` into your workspace with the
    `File -> Import -> Git` wizard.  Be sure to choose the
    "Import existing Eclipse projects" option at the appropriate step so
    that it reads the existing metadata.
1.  Run `Project -> Clean...` to give the build system a kick.
1.  In a terminal, run `./runalltests.sh` from the top-level git checkout.
    This isn't part of the build, but it will confirm that everything was
    built into `out` correctly.
1.  Optional: Right-click spc.jardesc and go through the `Create JAR` wizard
    to get a standalone `spc.jar`.

Eclipse will automatically run make whenever you touch one of the .g files,
and the Makefile takes care of running ANTLR.  The first time you open the
project, Eclipse won't see the generated files, so you may have to build it
and refresh the package explorer a couple of times to get it to be happy.
After that, it should rebuild without further messing around.
