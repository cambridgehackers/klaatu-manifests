#!/bin/bash
set -x
mkdir libnativehelper
ln -s ../dalvik/libnativehelper/include libnativehelper/
gzip frameworks/base/core/jni/Android.mk
gzip frameworks/base/tests/BrowserTestPlugin/jni/Android.mk
gzip frameworks/base/tools/layoutlib/Android.mk
gzip hardware/ril/mock-ril/Android.mk
gzip frameworks/base/graphics/jni/Android.mk
gzip build/core/tasks/apicheck.mk
gzip build/tools/apicheck/Android.mk
sed -i.001 -e "/^include.*external\/svox/d" build/target/product/sdk.mk
sed -i.001 -e "/(TARGET_ARCH),arm/s/arm/armfalse/" frameworks/base/cmds/app_process/Android.mk
sed -i.001 -e "/libsqlite/d" frameworks/base/media/jni/Android.mk
gzip frameworks/base/native/android/Android.mk
gzip system/core/sh/Android.mk
gzip sdk/emulator/qtools/Android.mk
sed -i.001 -e "/(LOCAL_PATH)\/ndk\/Android.mk/d" prebuilt/Android.mk
sed -i.001 -e "/^\$(LOCAL_INSTALLED_MODULE):/d" build/core/binary.mk
sed -i.001 -e "/^include/d" build/core/host_java_library.mk
sed -i.001 -e "/^include/d" build/core/java.mk
sed -i.001 -e "/^service zygote/a \ \ \ \ disabled" \
    -e "\$r $SCRIPT_DIR/../data/new_init.txt"  system/core/rootdir/init.rc
sed -i.001 -e "/BUILD_HOST_PREBUILT:=/s/BUILD_SYSTEM)\/host_prebuilt/TOPDIR)dalvik\/null/" \
    -e "/BUILD_JAVA_LIBRARY:=/s/BUILD_SYSTEM)\/java_library/TOPDIR)dalvik\/null/" \
    -e "/(filter 64-Bit, .(shell java -version/,/^endif/d" \
    -e "/find-jdk-tools-jar.sh/s/:=.*/:=/" \
    -e "/(HOST_JDK_TOOLS_JAR)),)/,/endif/d" \
    -e "/BUILD_DROIDDOC:=/s/BUILD_SYSTEM)\/droiddoc/TOPDIR)dalvik\/null/" build/core/config.mk
sed -i.001 -e "s/(.*java_version))/(true/" -e "s/(.*javac_version))/(true/" build/core/main.mk

#set TARGET_NO_RECOVERY=true as the default
sed -i.001 -e "s/\$(TARGET_NO_RECOVERY)/true/" build/core/Makefile 
if [ -e device/qcom/common/common.mk ] ; then
    # llvm config in device/qcom????
    sed -i.001 -e "/llvm-select.mk/s/^/#/" device/qcom/common/common.mk
fi
# add /data/usr/lib to default LD_LIBRARY_PATH
sed -i.001 -e "/\/system\/lib/s/,/,\"\/data\/usr\/lib\",/" bionic/linker/linker.c
# needed for qemu execution on ubuntu.... use old 
# ARM kernel hack: __get_tls() (*(__kernel_get_tls_t *)0xffff0fe0)()
# Instead of new armv6 instruction: __get_tls() asm ("mrc p15, 0, r0, c13, c0, 3"...
# is this also at 0xffff0ff0 ??? (code seems to imply...)
sed -i.001 -e "s/ifdef LIBC_STATIC/if 1/" bionic/libc/private/bionic_tls.h

# these perform local modifications to frameworks/base
sed -i.001 -e "s/android-logo-mask.png/cambridge-logo-mask.png/" frameworks/base/cmds/bootanimation/BootAnimation.cpp
sed -i.001 -e "/simphonebook\" },/s/}/},    { AID_RADIO, \"sigyn\" }/" frameworks/base/cmds/servicemanager/service_manager.c
#fixes for case-insensitive filesystems (macos)
sed -i.001 -e "/Case-insensitive filesystems not supported/d" build/core/main.mk
mv hardware/ti/omap4xxx/libtiutils/Semaphore.h hardware/ti/omap4xxx/libtiutils/big_Semaphore.h
sed -i.001 -e "s/\"Semaphore.h/\"big_Semaphore.h/" hardware/ti/omap4xxx/libtiutils/Semaphore.cpp 
sed -i.001 -e "s/\"Semaphore.h/\"big_Semaphore.h/" hardware/ti/omap4xxx/camera/inc/CameraHal.h

[ -e vendor ] || ln -s vendor_extra vendor

# QCOM
if [ -e vendor_extra/qcom/proprietary ] ; then
    ln -s ../../vendor_extra/qcom/proprietary vendor/qcom/proprietary
    sed -i.001 -e "/BOARD_USE_QCOM_LLVM_CLANG_RS/d" device/qcom/msm8960/BoardConfig.mk
    sed -i.001 -e "/llvm-select.mk/d" device/qcom/common/common.mk
    sed -i.001 \
        -e "/^LOCAL_MODULE_SUFFIX.*.apk/,/BUILD_PREBUILT/s/^/#/" \
        -e "/^LOCAL_MODULE_SUFFIX.*(COMMON_JAVA_PACKAGE_SUFFIX)/,/BUILD_PREBUILT/s/^/#/" \
        vendor_extra/qcom/proprietary/prebuilt_HY11/target/product/msm8960/Android.mk
    if [ -e vendor_extra/qcom/proprietary/clang-rs ] ; then
        gzip vendor_extra/qcom/proprietary/clang-rs/clang-host-build.mk
        find vendor_extra/qcom/proprietary/clang-rs/ -name Android.mk -exec gzip {} \;
    fi

    if [ -e vendor_extra/qcom/proprietary/flash10-bin ] ; then
        ls vendor_extra/qcom/proprietary/flash10-bin/*/Android.mk | while read filename ; do
            gzip $filename
        done
    fi
    [ -f vendor_extra/qcom/proprietary/neocore/Android.mk ] && gzip vendor_extra/qcom/proprietary/neocore/Android.mk
    [ -f device/qcom/common/generate_extra_images.mk ] && \
        sed -i.001 -e "/^RECOVERY_FROM_BOOT_PATCH/d" device/qcom/common/generate_extra_images.mk
    [ -f vendor_extra/qcom/proprietary/mm-http/Android.mk ] && \
        sed -i.001 -e "/include/d" vendor_extra/qcom/proprietary/mm-http/Android.mk
    [ -e prebuilts/ndk ] && (cd prebuilt/ndk; ln -s ../../prebuilts/ndk/* .)
    # 2.3.6
    [ -f vendor_extra/qcom/proprietary/common/build/vendorsetup.sh ] && \
        chmod a+x vendor_extra/qcom/proprietary/common/build/vendorsetup.sh
    sed -i.001 -e "s/ ndk\// prebuilt\/ndk\/android-ndk-r6\//" vendor_extra/qcom/proprietary/wfd/rtsp/Android.mk
    sed -i.001 -e "/FEATURE_GSIFF_ANDROID_NDK = 1/d" vendor_extra/qcom/proprietary/gps/isagnav/gsiff/Android.mk
    gzip vendor_extra/qcom/proprietary/wfd/wdsm/service/jni/Android.mk
    sed -i.001 -e "/\.apk/s/^/#/" vendor_extra/qcom/proprietary/common/config/device-vendor.mk
fi

THISVER=`make -f $SCRIPT_DIR/../data/printvar.mk PLATFORM_VERSION`
case ${THISVER:0:3} in
2.3)
    gzip frameworks/base/libs/rs/Android.mk
    sed -i.001 -e "/^droidcore: /s/doc-comment-check-docs//" frameworks/base/Android.mk
    sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/base/media/libstagefright/Android.mk
    ;;
4.0)
    gzip frameworks/base/libs/rs/Android.mk
    gzip frameworks/base/media/libstagefright/chromium_http/Android.mk
    #sed -i.001 -e "/^LOCAL_WHOLE_STATIC_LIBRARIES := /s/libfilterfw_jni//" -e "/libjnigraphics/d" system/media/mca/filterfw/Android.mk
    # For now, we'll always allow root programs to have permission
    sed -i.001 -e "/^bool checkPermission(/,/^{/ {/^{/s/$/if (uid == 0) return true;/}" frameworks/base/libs/binder/IServiceManager.cpp
    sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/base/media/libstagefright/Android.mk
    ;;
4.1)
    gzip frameworks/av/media/libstagefright/chromium_http/Android.mk
    sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/av/media/libstagefright/Android.mk
    sed -i.001 -e "/^include external\/junit\/Common.mk/d" frameworks/base/Android.mk
    #sed -i.001 -e "/^LOCAL_WHOLE_STATIC_LIBRARIES := /s/libfilterfw_jni//" -e "/libjnigraphics/d" frameworks/base/media/mca/filterfw/Android.mk
    sed -i.001 -e "/^ifneq (\$(TARGET_BUILD_PDK), true)/s/\$(TARGET_BUILD_PDK)/true/" frameworks/av/media/libstagefright/Android.mk

    #QCOM
    if [ -e vendor_extra/qcom/proprietary ] ; then
        [ -f vendor/qcom/opensource/bt-wlan-coex/btc/wlan_btc_usr_svc.c ] && \
            sed -i.001 -e "s/ LOGI/ ALOGI/" -e "s/ LOGE/ ALOGE/" -e "s/ LOG_FATAL/ ALOG_FATAL/" \
            vendor/qcom/opensource/bt-wlan-coex/btc/wlan_btc_usr_svc.c
        [ -f vendor/qcom/opensource/bt-wlan-coex/btces/btces_plat.h ] && \
            sed -i.001 -e "s/ LOGI/ ALOGI/" -e "s/ LOGE/ ALOGE/" -e "s/ LOG_FATAL/ ALOG_FATAL/" \
            vendor/qcom/opensource/bt-wlan-coex/btces/btces_plat.h
    fi
    ;;
esac
#bash bug: don't end the file with a conditional
true
