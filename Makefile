CLASSPATH=antlr-3.5.2-complete.jar:.
ANTLRFLAGS=

%.class : %.java
	javac -cp $(CLASSPATH) $<

all: SpokenCompiler.class

SpokenCompiler.class: VarType.class SymbolTable.class SpokenLangLexer.class SpokenLangParser.class \
	SLJavaEmitter.class SymEntry.class SLTreeNode.class SLTreeAdaptor.class VarDef1.class TypeInf.class \
	FunctionSym.class VarConstraint.class

SpokenLangLexer.java SpokenLangParser.java: SpokenLang.g
	java -cp $(CLASSPATH) org.antlr.Tool $(ANTLRFLAGS) SpokenLang.g

SLJavaEmitter.java: SLJavaEmitter.g SpokenLang.tokens
	java -cp $(CLASSPATH) org.antlr.Tool $(ANTLRFLAGS) SLJavaEmitter.g

VarDef1.java: VarDef1.g SpokenLang.tokens
	java -cp $(CLASSPATH) org.antlr.Tool $(ANTLRFLAGS) VarDef1.g

TypeInf.java: TypeInf.g SpokenLang.tokens
	java -cp $(CLASSPATH) org.antlr.Tool $(ANTLRFLAGS) TypeInf.g

clean:
	rm -f *.class *.tokens SpokenLangLexer.java SpokenLangParser.java SLJavaEmitter.java VarDef1.java TypeInf.java

test: SpokenCompiler.class
	./runalltests.sh
