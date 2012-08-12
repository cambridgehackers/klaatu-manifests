#
#set -e
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
sed -f $SCRIPT_DIR/strip_packages.sed <$1 >xx.strip.tmp
mv xx.strip.tmp $1
