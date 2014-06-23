#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh
. $script_dir/ndk_setup.sh
. $script_dir/multi_manifests.sh

setup_ndk

repo_init -u git://github.com/CyanogenMod/android.git -b jellybean
#repo_init -u https://android.googlesource.com/platform/manifest -b android-4.1.2_r1

$script_dir/strip-projects.sh .repo/manifest.xml


mkdir -p .repo/local_manifests

manifests="$(get_manifests)"
if [ -n "$manifests" ]; then cp $manifests .repo/local_manifests/; fi

cat <<EOF >.repo/local_manifests/00-matson.xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remove-project name="CyanogenMod/android_frameworks_av" />
  <remove-project name="CyanogenMod/android_frameworks_base" />
  <remove-project name="CyanogenMod/android_frameworks_native" />
  <!-- remove-project name="CyanogenMod/android_packages_apps_Launcher2" /-->

  <remote name="matson" fetch="https://github.com/matson-hall" />
  <!-- matson start -->
  <project path="frameworks/base" name="android_frameworks_base" remote="matson" revision="jb-cubieboard" />
  <project path="device/allwinner/cubieboard" name="android_device_allwinner_cubieboard" remote="matson" revision="jb-cubieboard" />
  <project path="packages/apps/Launcher2" name="android_packages_apps_Launcher2" remote="matson" revision="jb-cubieboard" />
  <project path="hardware/realtek" name="android_hardware_realtek" remote="matson" revision="jb-cubieboard" />
  <project path="vendor/allwinner" name="proprietary_vendor_allwinner" remote="matson" revision="jb-cubieboard" />
  <project path="frameworks/native" name="android_frameworks_native" remote="matson" revision="jb-cubieboard" />
  <project path="external/cedarx" name="android_external_cedarx" remote="matson" revision="jb-cubieboard" />
  <project path="device/allwinner/common" name="android_device_allwinner_common" remote="matson" revision="jb-cubieboard" />
  <project path="frameworks/av" name="android_frameworks_av" remote="matson" revision="jb-cubieboard" />
  <project path="kernel/allwinner/common" name="linux-sunxi" remote="matson" revision="jb-cubieboard" />
  <project path="tools" name="allwinner-pack-tools" remote="matson" revision="jb-cubieboard" />
  <!-- matson end -->
</manifest>
EOF

export KLAATU_DEFAULT_UI=$(get_default_ui)

repo_sync

#sed -i 's:.*NO_RECOVERY.*::g' $script_dir/fixup_common.sh
if [ -n "$manifests" ]; then
$script_dir/fixup_common.sh
fi

. build/envsetup.sh
lunch full_cubieboard-userdebug

#make update-api
make -j${NUM_CPUS}

ln -snf boot.img out/target/product/cubieboard/recovery.img
tools/pack-cm.sh

cp -a tools/pack/sun4i_crane_cubieboard.img out/target/product/cubieboard/
