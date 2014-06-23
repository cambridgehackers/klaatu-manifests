#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh
. $script_dir/ndk_setup.sh
. $script_dir/multi_manifests.sh

setup_ndk

repo_init -u https://android.googlesource.com/platform/manifest -b android-4.4.2_r1

#$script_dir/strip-projects.sh .repo/manifest.xml

set_ui_defaults qt kivy busybox

mkdir -p .repo/local_manifests
manifests="$(get_manifests)"
if [ -n "$manifests" ] ; then cp $manifests .repo/local_manifests/; fi
cat <<EOF >.repo/local_manifests/local_manifest.xml
<manifest>
  <remote  name="aosp" fetch=".." />
  <project path="device/ti/panda" name="device/ti/panda" revision="refs/tags/android-4.3.1_r1"/>
</manifest>
EOF

export KLAATU_DEFAULT_UI=$(get_default_ui)

repo_sync

if [ -n "$manifests" ] ; then
$script_dir/fixup_common.sh
fi

# download latest driver from: http://code.google.com/android/nexus/drivers.html#panda
imgtec=imgtec-panda-20130603-539d1ac3.tgz
[ -f "$imgtec" ] || wget "https://dl.google.com/dl/android/aosp/$imgtec"
tar zxvf "$imgtec"
chmod +x extract-imgtec-panda.sh
yes "I ACCEPT" | ./extract-imgtec-panda.sh

. build/envsetup.sh

lunch full_panda-userdebug

make -j${NUM_CPUS}

cp -a ./device/ti/panda/*bin out/target/product/panda
cp -a ./device/ti/panda/usbboot out/target/product/panda
