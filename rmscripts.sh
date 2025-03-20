#!/bin/bash
# first parameter is the blfs tool's script folder
# second parameter is the blfs tool's installed packages xml file

set -e

# Check if the script folder is specified as an argument
if [ -z "$1" ] ; then
    echo "Please specify the BLFS tool's script folder as the first argument." >&2
    exit 1
fi

# Check if the given script folder exists
if [ ! -d "$1" ] ; then
    echo "The specified script folder does not exist." >&2
    exit 2
fi

# Check if the installed packages XML file is specified as an argument
if [ -z "$2" ] ; then
    echo "Please specify the BLFS tool's installed packages XML file as the second argument." >&2
    exit 3
fi

# Check if the installed packages XML file exists
if [ ! -f "$2" ] ; then
    echo "The specified installed packages XML file does not exist." >&2
    exit 4
fi

# Add slash to script path if not there yet
if [[ "$1" != */ ]] ; then
    SCRIPTPATH="$1/"
else
    SCRIPTPATH="$1"
fi

# Find and remove all the scripts that would install a package already mentioned in the installed packages file
grep "$2" -f <(find "$SCRIPTPATH" -type f -printf '%f\n' | awk -F'-z-' '{print "<name>"$2"</name>"}') | \
    while read -r line
    do
        rm -v "$(find "$SCRIPTPATH" -name "$(echo "$line" | sed 's/<name>/*-/g' | sed 's|</name>||g')" -type f)"
    done
