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
inFile=$class.in
compare=$class.expected
testNum=${class#test_}
topDir=$( dirname "$0" )

java -cp $topDir/lib/antlr-3.5.2-complete.jar:$topDir/bin org.bxg.spokencompiler.SpokenCompiler "$input"
if [ $? = 0 ]; then
    echo "-- Running $class --"
    cd "$spkDir"
	if [ -f $inFile ]; then
	    java $class <$inFile
	else
    	java $class
	fi
	echo "-- Done -- "
fi
