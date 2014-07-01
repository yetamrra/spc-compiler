CLASSPATH=../lib/antlr-3.5.2-complete.jar:.
ANTLRFLAGS=

%.class : %.java
	javac -cp $(CLASSPATH) $<

all:
	$(MAKE) -C org/bxg/spokencompiler

clean:
	rm -f *.class *.tokens SpokenLangLexer.java SpokenLangParser.java SLJavaEmitter.java VarDef1.java TypeInf.java
	$(MAKE) -C org/bxg/spokencompiler clean

test: SpokenCompiler.class
	./runalltests.sh

.PHONY: all clean
