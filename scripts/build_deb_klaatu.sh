#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh
. $script_dir/ndk_setup.sh

setup_ndk

release=4.4.2_r1
vendor_build=deb-kot49h
vendor_xml=`$script_dir/get_vendor_build.sh $vendor_build`
klaatu_manifests=$script_dir/../manifests

repo init -u https://android.googlesource.com/platform/manifest -b android-$release
#$script_dir/strip-projects.sh .repo/manifest.xml

mkdir -p .repo/local_manifests
cp $vendor_xml .repo/local_manifests/
cp $klaatu_manifests/klaatu-common.xml .repo/local_manifests/
cp $klaatu_manifests/busybox.xml .repo/local_manifests/
cp $klaatu_manifests/klaatu-qt.xml .repo/local_manifests/
cp $klaatu_manifests/klaatu-kivy.xml .repo/local_manifests/

repo sync
$script_dir/fixup_common.sh

export KLAATU_DEFAULT_UI=kivy

. build/envsetup.sh
lunch aosp_deb-userdebug

make -j$NUM_CPUS
