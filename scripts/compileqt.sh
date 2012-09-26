#!/bin/bash
set -e
set -x
# ln -s ~/bionicsf-manifests/manifests/cambridge-stripped-4.0.4_r1.2.xml .repo/local_manifest.xml
rm -rf bionicsf-* loki mysysroot outdir cambridge-qt*
[ -e mysysroot ] || mkdir mysysroot
[ -e outdir ] || mkdir outdir
cd mysysroot
~/klaatu-manifests/scripts/install_sysroot.sh ~/rpm 4.0.4_r1.2 maguro
cd ..
export KLAATU_SYSROOT=`pwd`/mysysroot/aroot
INSTALL_TARGET=`pwd`/outdir

git clone git://gitorious.org/+cambridgehackers/qt/cambridge-qtbase.git
(cd cambridge-qtbase; git checkout remotes/origin/bionicsf_2012-09-12 -b testing)
git clone git://gitorious.org/+cambridgehackers/qt/cambridge-qtjsbackend.git
(cd cambridge-qtjsbackend; git checkout remotes/origin/bionicsf_2012-09-12 -b testing)
git clone git://gitorious.org/+cambridgehackers/qt/cambridge-qtdeclarative.git
(cd cambridge-qtdeclarative; git checkout remotes/origin/bionicsf_2012-09-12 -b testing)
git clone ssh://leda/git/loki

cd cambridge-qtbase
./configure -no-c++11 -no-linuxfb -no-kms \
    	-no-accessibility -opensource -confirm-license \
        -device linux-android-maguro-es-g++-klaatu \
        -nomake examples -nomake demos -nomake tests \
        -opengl es2 -no-glib -no-c++11 -prefix /data/usr
make -j32
INSTALL_ROOT=$INSTALL_TARGET make install
echo -e "[Paths]\nPrefix=$INSTALL_TARGET/data/usr\nHostData=$INSTALL_TARGET/data/usr" >$INSTALL_TARGET/data/usr/bin/qt.conf
cd ../cambridge-qtjsbackend
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
make install
cd ../cambridge-qtdeclarative
$INSTALL_TARGET/data/usr/bin/qmake
make -j32
make install
cd ../loki
$INSTALL_TARGET/data/usr/bin/qmake
#make -j32
