#
#set -e
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
[ -e $1.orig ] || cp $1 $1.orig
sed -i.001 -f $SCRIPT_DIR/sed/strip_packages.sed -e "s/git:\/\/codeaurora.org/../" -e "s/git:\/\/git.omapzoom.org/../" $1
