#
#set -e
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
ls tmp/android-[0-9]*.xml | while read filename ; do
    sed -f $SCRIPT_DIR/strip_packages.sed <$filename >xx.tmp
    mv xx.tmp $filename
done
