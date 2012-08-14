#
#set -e
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
sed -f $SCRIPT_DIR/sed/strip_packages.sed <$1 >xx.strip.tmp
[ -e $1.orig ] || mv $1 $1.orig
mv xx.strip.tmp $1
