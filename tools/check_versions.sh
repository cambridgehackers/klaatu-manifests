#!/bin/bash
set -e
#set -x

export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
[ -e manifest ] || git clone git://codeaurora.org/platform/manifest.git
[ -e build ] || git clone git://codeaurora.org/platform/build
[ -e kernel ] || git clone git://codeaurora.org/kernel/msm kernel

SKIP="1"
#for all branches in the manifest
(cd manifest/; git branch -a | fgrep -v aosp | fgrep remotes/origin/ | fgrep -v HEAD | sed -e "s/.*\///") | while read ANDROID_VERSION ; do
    echo HEAD $ANDROID_VERSION
    if test "$ANDROID_VERSION" == "gingerbread" ; then
        SKIP="0"
    fi
    if test $SKIP == "0" ; then
        (cd manifest; git reset --hard -q; git checkout -q $ANDROID_VERSION )
        # look at all files in a branch
        ls manifest/*xml | while read ANDROID_MANIFEST_FILE ; do
            if test "$ANDROID_MANIFEST_FILE" != "manifest/default.xml" ; then
                BUILDSHA=`fgrep '"build"' $ANDROID_MANIFEST_FILE | sed -e "s/.*revision=\"//" -e "s/\".*//"`
                KERNELSHA=`fgrep '"kernel"' $ANDROID_MANIFEST_FILE | sed -e "s/.*revision=\"//" -e "s/\".*//"`
                (cd build; git reset --hard -q; git checkout -q $BUILDSHA )
                (cd kernel; git reset --hard -q; git checkout -q $KERNELSHA Makefile )
                echo `make -f $SCRIPT_DIR/../scripts/printvar.mk PLATFORM_VERSION` \
                    `head -4 kernel/Makefile | sed -e "s/.*= //" | sed -e :a -e '$!N; s/\n/./; ta' -e "s/\.\.*/./g" -e "s/\.EXTRAVERSION.*=//" ` \
                    `make -f $SCRIPT_DIR/../scripts/printvar.mk BUILD_ID` $ANDROID_VERSION `basename $ANDROID_MANIFEST_FILE`
            fi
        done
    fi
done
echo "done"
