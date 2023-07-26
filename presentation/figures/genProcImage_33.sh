#!/bin/sh

os=`uname | cut -b 1-6`
if [ $os == "CYGWIN" ]
then
	PROCESSING=/cygdrive/c/Users/John/Documents/processing-4.2/processing-java.exe
	tmp=`pwd | cut -d/ -f6- | sed "s-/-\\\\\-g"`
	FOLDER=$USERPROFILE\\${tmp}\\
else
	PROCESSING=./processing-java
	FOLDER=`pwd`/
fi

num=33

$PROCESSING --sketch=${FOLDER}ExpressionGen --run example_${num}
mv ExpressionGen/example_${num}.png image_${num}.png
rm ExpressionGen/data_example_${num}.cache
