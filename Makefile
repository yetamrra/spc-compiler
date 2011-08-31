CLASSPATH=antlrworks-1.4.2.jar:.
ANTLRFLAGS=

%.class : %.java
	javac -cp $(CLASSPATH) $<

all: SpokenCompiler.class

SpokenCompiler.class: SpokenLangLexer.class SpokenLangParser.class SLJavaEmitter.class

SpokenLangLexer.java SpokenLangParser.java: SpokenLang.g
	java -cp $(CLASSPATH) org.antlr.Tool $(ANTLRFLAGS) SpokenLang.g

SLJavaEmitter.java: SLJavaEmitter.g SpokenLang.tokens
	java -cp $(CLASSPATH) org.antlr.Tool $(ANTLRFLAGS) -trace SLJavaEmitter.g

clean:
	rm -f *.class *.tokens SpokenLangLexer.java SpokenLangParser.java SLJavaEmitter.java
