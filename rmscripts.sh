#!/bin/bash
# first parameter is the blfs tool's script folder
# second parameter is the blfs tool's installed packages xml file

if [ -z "$1" ]
then
	echo "Please specify the blfs tool's script folder as the first argument!"
	exit -1
fi

if [ -z "$2" ]
then
        echo "Please specify the blfs tool's installed packages xml file as the second argument!"
	exit -1
fi

if [[ "$1" != */ ]]
then
	SCRIPTPATH=$(echo "$1"/)
else
	SCRIPTPATH="$1"
fi

grep "$2" -f <(ls "$SCRIPTPATH" | awk -F'-z-' '{print "<name>"$2"</name>"}') | while read line ; do rm -v "$SCRIPTPATH"$(echo "$line" | sed 's/<name>/*-/g' | sed 's|</name>||g') ; done

