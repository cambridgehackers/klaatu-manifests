#!/bin/bash
set -e
set -x
[ -e outdir ] || mkdir outdir
export KLAATU_SYSROOT=`pwd`/aroot
export INSTALL_TARGET=`pwd`/outdir
repo init -u git://gitorious.org/cambridge/klaatu-manifests.git -m manifests/qt_2012-09-12.xml
repo sync

../.repo/manifests/scripts/install_sysroot.sh ~/rpm 4.0.4_r1.2 maguro

# first build qtbase to get qmake
cd qtbase
./configure -no-c++11 -no-linuxfb -no-kms \
    	-no-accessibility -opensource -confirm-license \
        -device linux-android-maguro-es-g++-klaatu \
        -nomake examples -nomake demos -nomake tests \
        -opengl es2 -no-glib -no-c++11 -prefix /data/usr
make -j32
INSTALL_ROOT=$INSTALL_TARGET make install
echo -e "[Paths]\nPrefix=$INSTALL_TARGET/data/usr\nHostData=$INSTALL_TARGET/data/usr" >$INSTALL_TARGET/data/usr/bin/qt.conf

# compile remaining qt modules
cd ../qtjsbackend
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
make install
cd ../qtdeclarative
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
make install
cd tools
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
make install

# now compile services
(cd aroot; make -j32)

# now compile the test programs
cd ../../loki
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
