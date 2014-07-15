#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh
. $script_dir/multi_manifests.sh

repo init -u https://android.googlesource.com/platform/manifest -b android-4.3_r2.1

set_ui_defaults qt busybox

manifests="$(get_manifests)"

mkdir -p .repo/local_manifests

if [ -n "$manifests" ]; then cp $manifests .repo/local_manifests/; fi

cat <<EOF >.repo/local_manifests/local_manifest.xml
<manifest>
  <remote name="csimmonds" fetch="https://github.com/csimmonds/" />
  <project path="device/ti/beagleboneblack" name="bbb-android-device-files" remote="csimmonds" revision="jb4.3-fastboot"/>
</manifest>
EOF

export KLAATU_DEFAULT_UI=$(get_default_ui)

repo_sync

sed -i s:wpa_supplicant.conf:: external/klaatu-qmlscene/Android.mk

if [[ -n "$manifests" ]] && [[ "$manifests" != *zygote* ]]; then
$script_dir/fixup_common.sh
fi

. build/envsetup.sh

lunch beagleboneblack-eng

export PATH=`pwd`/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin:$PATH

[ -d kernel ] || git clone -v --depth=1 -b rowboat-am335x-kernel-3.2 git://gitorious.org/rowboat/kernel.git

( cd kernel ; \
make ARCH=arm CROSS_COMPILE=arm-eabi- am335x_evm_android_defconfig ; \
make ARCH=arm CROSS_COMPILE=arm-eabi- zImage -j${NUM_CPUS} )
cp kernel/arch/arm/boot/zImage device/ti/beagleboneblack/kernel

make -j${NUM_CPUS}

[ -d hardware/ti/sgx ] || git clone --depth=1 -b ti_sgx_sdk-ddk_1.10-jb-4.3 git://git.gitorious.org/rowboat/hardware-ti-sgx.git hardware/ti/sgx
sed -i 's:^TARGETFS_INSTALL_DIR=$(ANDROID_ROOT_DIR)/out/target/product/$(TARGET_PRODUCT)/:TARGETFS_INSTALL_DIR=$(ANDROID_ROOT_DIR)/device/ti/beagleboneblack/sgx:' hardware/ti/sgx/Rules.make

sed -i 's#OUT\s*?=\s*$(TOP)/eurasiacon#OUT := $(TOP)/eurasiacon#' hardware/ti/sgx/eurasiacon/build/linux2/config/core.mk

( cd hardware/ti/sgx; \
make TARGET_PRODUCT=beagleboneblack OMAPES=4.x ANDROID_ROOT_DIR="${ANDROID_BUILD_TOP}" W=1; \
make TARGET_PRODUCT=beagleboneblack OMAPES=4.x ANDROID_ROOT_DIR="${ANDROID_BUILD_TOP}" W=1 install ) || true

make -j${NUM_CPUS}

[ -d u-boot ] || git clone --depth=1 -b am335x-v2013.01.01-bbb-fb https://github.com/csimmonds/u-boot.git
( cd u-boot;  make CROSS_COMPILE=arm-eabi- distclean; make CROSS_COMPILE=arm-eabi- am335x_evm_config; make CROSS_COMPILE=arm-eabi- )
cp -af u-boot/u-boot.img u-boot/MLO out/target/product/beagleboneblack/

