#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh

klaatu_manifests=$script_dir/../manifests

repo_init -u https://android.googlesource.com/platform/manifest -b android-4.2.1_r1

#$script_dir/strip-projects.sh .repo/manifest.xml

mkdir -p .repo/local_manifests
cp $klaatu_manifests/manifests/qt_2012-05-30-generic.xml .repo/local_manifests/
cat <<EOF >.repo/local_manifests/local_manifest.xml
<manifest>
  <remote name="cambridge" fetch="git://gitorious.org/cambridge/" />
  <project path="external/klaatu-qt-demos" name="klaatu-qt-demos" remote="cambridge" revision="master"/>

  <remote name="googlesource" fetch="https://android.googlesource.com" />
  <project name="kernel/omap" path="kernel" remote="googlesource" revision="cb5fc502c60be9305c5a007be335e860d9e7c0cb"/>
</manifest>
EOF

repo_sync

#$script_dir/fixup_common.sh

# download latest driver from: http://code.google.com/android/nexus/drivers.html#panda
#imgtec=imgtec-panda-20120807-c4e99e89.tgz
imgtec=imgtec-panda-20120807-c4e99e89.tgz
[ -f "$imgtec" ] || wget "https://dl.google.com/dl/android/aosp/$imgtec"
tar zxvf "$imgtec"
chmod +x extract-imgtec-panda.sh
yes "I ACCEPT" | ./extract-imgtec-panda.sh
( cd device/ti/panda/ ; git checkout jb-mr1.1-dev-plus-aosp)

. build/envsetup.sh

lunch full_panda-userdebug

make -j${NUM_CPUS}
make
cp -a ./device/ti/panda/*bin out/target/product/panda
cp -a ./device/ti/panda/usbboot out/target/product/panda
