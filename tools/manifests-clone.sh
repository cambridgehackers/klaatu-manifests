#!/bin/bash
set -e
TMPMANIFEST=xx.manifest
rm -rf $TMPMANIFEST tmp
git clone -q https://android.googlesource.com/platform/manifest $TMPMANIFEST
(cd $TMPMANIFEST; git branch -a >../xx.branchlist)
[ -e tmp ] | mkdir tmp
fgrep remotes/origin/ xx.branchlist | fgrep -v HEAD | sed -e "s/remotes\/origin\///" | while read bname; do
    echo BRANCH $bname
    (cd $TMPMANIFEST; git checkout -q remotes/origin/$bname)
    cp $TMPMANIFEST/default.xml tmp/$bname.xml
    mkdir -p tmp/$bname
    (cd $TMPMANIFEST; tar cf - --exclude=default.xml --exclude=.git .) | (cd tmp/$bname; tar xf -)
    true `rmdir tmp/$bname 2>/dev/null `
done
rm -rf $TMPMANIFEST xx.branchlist
