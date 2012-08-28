#!/bin/bash
if test -z "$1" -o -z "$2" ; then
    echo "hexpatch.sh <patchfile> <outfile>"
    exit 1
fi
cat $1 | while read line ; do
    echo $line | xxd -r - $2
done
