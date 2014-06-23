#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh
. $script_dir/ndk_setup.sh
. $script_dir/multi_manifests.sh

setup_ndk

release=4.4.2_r1
vendor_build=deb-kot49h
vendor_xml=`$script_dir/get_vendor_build.sh $vendor_build`

repo init -u https://android.googlesource.com/platform/manifest -b android-$release
#$script_dir/strip-projects.sh .repo/manifest.xml

set_ui_defaults kivy qt busybox

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
lunch aosp_deb-userdebug

make -j$NUM_CPUS
