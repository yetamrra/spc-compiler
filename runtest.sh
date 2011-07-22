#!/bin/bash

if [ -n "$1" ]; then
    input="$1"
else
    input="hello.spk"
fi
class=${input%.spk}
output=$class.java

java -cp antlrworks-1.4.2.jar:. SpokenCompiler "$input"
if [ $? = 0 ]; then
    java $class
fi
