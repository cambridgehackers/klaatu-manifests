#
#set -e
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
ls tmp/android-[0-9]*.xml | while read filename ; do
    $SCRIPT_DIR/strip-projects.sh $filename
done
