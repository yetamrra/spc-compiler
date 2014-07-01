CLASSPATH=antlr-3.5.2-complete.jar:.
ANTLRFLAGS=

%.class : %.java
	javac -cp $(CLASSPATH) $<

all: 
	$(MAKE) -C src

clean:
	rm -f *.class *.tokens SpokenLangLexer.java SpokenLangParser.java SLJavaEmitter.java VarDef1.java TypeInf.java
	$(MAKE) -C tests clean

test: 
	./runalltests.sh
