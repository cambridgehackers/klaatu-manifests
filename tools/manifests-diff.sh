#
#set -e
#set -x
LASTFILE=''
ls tmp/android-[0-9]*.xml | while read filename ; do
    if [ "$LASTFILE" != "" ] ; then
        echo diff $LASTFILE $filename
        diff -B -w $LASTFILE $filename | fgrep -v '<default revision="refs/tags/' | sed '/^6c6$/d' | fgrep -v 'path="prebuilt'
    fi
    LASTFILE=$filename
done
