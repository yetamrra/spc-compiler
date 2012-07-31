#!/bin/bash

if [ -n "$1" ]; then
    input="$1"
else
    echo "Usage: $0 sourcefile.spk"
	exit 1
fi
spkDir=$( dirname "$input" )
spkFile=$( basename "$input" )
class=${spkFile%.spk}
output=$class.java
compare=$class.expected
testNum=${class#test_}

java -cp antlrworks-1.4.2.jar:. SpokenCompiler "$input"
if [ $? = 0 ]; then
    echo "-- Running $class --"
    cd "$spkDir"
    java $class
	echo "-- Done -- "
fi
