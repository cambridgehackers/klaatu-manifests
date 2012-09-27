#!/bin/bash
set -e
set -x
[ -e outdir ] || mkdir outdir
KLAATU_TOPDIR=`pwd`
export KLAATU_SYSROOT=$KLAATU_TOPDIR/aroot
export INSTALL_TARGET=$KLAATU_TOPDIR/outdir
#MANIFEST=qt_2012-09-12.xml
MANIFEST=qt_2012-05-30.xml
repo init -u git://gitorious.org/cambridge/klaatu-manifests.git -m manifests/$MANIFEST
repo sync

.repo/manifests/scripts/install_sysroot.sh ~/klaatu-rpm 4.0.4 maguro

# first build qtbase to get qmake
cd $KLAATU_TOPDIR/qtbase
if test "$MANIFEST" != "qt_2012-05-30.xml" ; then
    EXTRAOPTIONS="-no-c++11 -no-linuxfb -no-kms"
fi
./configure $EXTRAOPTIONS \
        -device linux-android-maguro-es-g++-klaatu \
    	-no-pch -no-accessibility -opensource -confirm-license \
        -nomake examples -nomake demos -nomake tests \
        -opengl es2 -no-glib -prefix /data/usr
make -j32
INSTALL_ROOT=$INSTALL_TARGET make install
echo -e "[Paths]\nPrefix=$INSTALL_TARGET/data/usr\nHostData=$INSTALL_TARGET/data/usr" >$INSTALL_TARGET/data/usr/bin/qt.conf

# compile remaining qt modules
cd $KLAATU_TOPDIR/qtjsbackend
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
make install
cd $KLAATU_TOPDIR/qtdeclarative
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
make install
cd tools
# compile qmlscene
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
make install

# now compile added services
cd $KLAATU_TOPDIR/aroot
source build/envsetup.sh; lunch full_maguro-userdebug
make showcommands
$KLAATU_TOPDIR/.repo/manifests/scripts/makeusr

# now compile the test programs
cd $KLAATU_TOPDIR/loki
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
