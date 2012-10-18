#
#set -e
set -x
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
[ -e $1.orig ] || cp $1 $1.orig
sed -i.001 -f $SCRIPT_DIR/../data/strip_packages.sed \
    -e "/<\/manifest>/r $SCRIPT_DIR/../data/new_projects.xml" \
    -e "/<\/manifest>/d" \
    $1
