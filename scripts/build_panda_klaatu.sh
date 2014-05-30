#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh

klaatu_manifests=$script_dir/../manifests

repo_init -u https://android.googlesource.com/platform/manifest -b android-4.4.2_r1

#$script_dir/strip-projects.sh .repo/manifest.xml

mkdir -p .repo/local_manifests
cp $klaatu_manifests/klaatu-common.xml .repo/local_manifests/
cp $klaatu_manifests/busybox.xml .repo/local_manifests/
cp $klaatu_manifests/klaatu-qt.xml .repo/local_manifests/
cat <<EOF >.repo/local_manifests/local_manifest.xml
<manifest>
  <remote  name="aosp" fetch=".." />
  <project path="device/ti/panda" name="device/ti/panda" revision="refs/tags/android-4.3.1_r1"/>
</manifest>
EOF

export KLAATU_DEFAULT_UI=qt

repo_sync

#$script_dir/fixup_common.sh

# download latest driver from: http://code.google.com/android/nexus/drivers.html#panda
imgtec=imgtec-panda-20130603-539d1ac3.tgz
[ -f "$imgtec" ] || wget "https://dl.google.com/dl/android/aosp/$imgtec"
tar zxvf "$imgtec"
chmod +x extract-imgtec-panda.sh
yes "I ACCEPT" | ./extract-imgtec-panda.sh

. build/envsetup.sh

lunch full_panda-userdebug

make -j${NUM_CPUS}
make
cp -a ./device/ti/panda/*bin out/target/product/panda
cp -a ./device/ti/panda/usbboot out/target/product/panda
