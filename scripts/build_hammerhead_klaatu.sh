#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh
. $script_dir/patches.sh
. $script_dir/ndk_setup.sh
. $script_dir/multi_manifests.sh

setup_ndk

release=4.4.4_r1
vendor_build=hammerhead-ktu84p
vendor_xml=`$script_dir/get_vendor_build.sh $vendor_build`

repo init -u https://android.googlesource.com/platform/manifest -b android-$release "$@"

set_ui_defaults kivy qt busybox

mkdir -p .repo/local_manifests
cp $vendor_xml .repo/local_manifests/
cat <<EOF >.repo/local_manifests/local_manifest.xml
<manifest>
  <project path="kernel" name="kernel/msm" revision="android-msm-hammerhead-3.4-kitkat-mr2" />
</manifest>
EOF
manifests="$(get_manifests)"
if [ -n "$manifests" ]; then cp $manifests .repo/local_manifests/; fi


repo sync "$@"

if [ -n "$manifests" ]; then
$script_dir/fixup_common.sh
fi

export KLAATU_DEFAULT_UI=$(get_default_ui)

patch_build

. build/envsetup.sh

lunch aosp_hammerhead-userdebug

make -j${NUM_CPUS}
