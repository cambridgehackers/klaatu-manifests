#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh
. $script_dir/ndk_setup.sh
. $script_dir/multi_manifests.sh

setup_ndk

release=4.2.2_r1.2
vendor_build=mako-jdq39
vendor_xml=`$script_dir/get_vendor_build.sh $vendor_build`

repo init -u https://android.googlesource.com/platform/manifest -b android-$release
$script_dir/strip-projects.sh .repo/manifest.xml

mkdir -p .repo/local_manifests
cp $vendor_xml .repo/local_manifests/
manifests="$(get_manifests)"
if [ -n "$manifests" ]; then cp $manifests .repo/local_manifests/; fi

repo sync
if [ -n "$manifests" ]; then
$script_dir/fixup_common.sh
fi

export KLAATU_DEFAULT_UI=$(get_default_ui)

. build/envsetup.sh
lunch full_mako-userdebug

make -j$NUM_CPUS
