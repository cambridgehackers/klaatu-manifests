#
#set -e
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
[ -e $1.orig ] || cp $1 $1.orig
sed -i.001 -f $SCRIPT_DIR/sed/strip_packages.sed $1
REPLSTR=`echo $ANDROID_GENERIC_HOST_CODEAURORA | sed -e "s/\//\\\\\\\\\//g"`
sed -i.002 -e "s/git:\/\/codeaurora.org/$REPLSTR/" $1
REPLSTR=`echo $ANDROID_GENERIC_HOST_OMAPZOOM | sed -e "s/\//\\\\\\\\\//g"`
#sed -i.001 -e "s/git:\/\/git.omapzoom.org/$REPLSTR/" $1
