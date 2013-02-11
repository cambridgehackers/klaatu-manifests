#!/bin/bash
set -e
set -x
export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
#first install gcc
if [ ! -d aroot ] ; then
    ~/klaatu-manifests/scripts/install_sysroot.sh ~/klaatu-rpm 4.0.4 maguro
    #add it to PATH
    pushd aroot/toolchain/bin
    ln -s arm-bionic-eabi-addr2line arm-linux-addr2line
    ln -s arm-bionic-eabi-ar arm-linux-ar
    ln -s arm-bionic-eabi-as arm-linux-as
    ln -s arm-bionic-eabi-c++ arm-linux-c++
    ln -s arm-bionic-eabi-c++filt arm-linux-c++filt
    ln -s arm-bionic-eabi-cpp arm-linux-cpp
    ln -s arm-bionic-eabi-g++ arm-linux-g++
    ln -s arm-bionic-eabi-gcc arm-linux-gcc
    ln -s arm-bionic-eabi-gcov arm-linux-gcov
    ln -s arm-bionic-eabi-gdb arm-linux-gdb
    ln -s arm-bionic-eabi-gdbtui arm-linux-gdbtui
    ln -s arm-bionic-eabi-gprof arm-linux-gprof
    ln -s arm-bionic-eabi-ld arm-linux-ld
    ln -s arm-bionic-eabi-ld.bfd arm-linux-ld.bfd
    ln -s arm-bionic-eabi-ld.gold arm-linux-ld.gold
    ln -s arm-bionic-eabi-nm arm-linux-nm
    ln -s arm-bionic-eabi-objcopy arm-linux-objcopy
    ln -s arm-bionic-eabi-objdump arm-linux-objdump
    ln -s arm-bionic-eabi-ranlib arm-linux-ranlib
    ln -s arm-bionic-eabi-readelf arm-linux-readelf
    ln -s arm-bionic-eabi-run arm-linux-run
    ln -s arm-bionic-eabi-size arm-linux-size
    ln -s arm-bionic-eabi-strings arm-linux-strings
    ln -s arm-bionic-eabi-strip arm-linux-strip
    popd
fi
#now compile X
PATH=`pwd`/aroot/toolchain/bin:$PATH \
    DISCIMAGE=`pwd`/out \
    CROSS_COMPILE=arm-linux- \
    jhbuild -f $SCRIPT_DIR/crossx.jhbuild update xserver
if [ ! -e sources/patched ] ; then
    patch -p0 <$SCRIPT_DIR/cross_android.patch
    touch sources/patched
fi
PATH=`pwd`/aroot/toolchain/bin:$PATH \
    DISCIMAGE=`pwd`/out \
    CROSS_COMPILE=arm-linux- \
    jhbuild -f $SCRIPT_DIR/crossx.jhbuild build xserver
