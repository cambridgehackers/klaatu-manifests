#!/bin/bash
set -e
set -x
#first install gcc
~/klaatu-manifests/scripts/install_sysroot.sh ~/klaatu-rpm 4.0.4 maguro
#add it to PATH
#now compile X
DISCIMAGE=`pwd`/foo CROSS_COMPILE=arm-linux- jhbuild -f crossx.jhbuild build xserver
