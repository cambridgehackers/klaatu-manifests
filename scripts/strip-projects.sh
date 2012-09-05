#
#set -e
set -x
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
[ -e $1.orig ] || cp $1 $1.orig
sed -i.001 -f $SCRIPT_DIR/sed/strip_packages.sed \
    -e "/<\/manifest>/r $SCRIPT_DIR/new_projects.xml" \
    -e "/<\/manifest>/d" \
    -e "s/git:\/\/codeaurora.org/../" \
    -e "s/git:\/\/git.omapzoom.org/../" \
    $1
