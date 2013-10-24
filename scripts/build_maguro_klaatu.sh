#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh

release=4.1.2_r2
vendor_build=maguro-jzo54k
vendor_xml=`$script_dir/get_vendor_build.sh $vendor_build`
klaatu_manifests=$script_dir/../manifests

repo init -u https://android.googlesource.com/platform/manifest -b android-$release
mkdir -p .repo/local_manifests
cp $vendor_xml .repo/local_manifests/
cp $klaatu_manifests/klaatu-common.xml .repo/local_manifests/
cp $klaatu_manifests/busybox.xml .repo/local_manifests/

repo sync

. build/envsetup.sh
lunch full_maguro-userdebug

make -j$NUM_CPUS
