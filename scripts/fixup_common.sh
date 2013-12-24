#!/bin/bash
[ ! -f .fixup_applied ] || exit 0
set -x

gzip dalvik/Android.mk
gzip dalvik/libnativehelper/Android.mk
gzip dalvik/jni/Android.mk
gzip frameworks/base/tests/BrowserTestPlugin/jni/Android.mk
gzip frameworks/base/tools/layoutlib/Android.mk
gzip hardware/ril/mock-ril/Android.mk
gzip frameworks/base/graphics/jni/Android.mk
gzip build/core/tasks/apicheck.mk
gzip build/tools/apicheck/Android.mk
sed -i.001 -e "/^include.*external\/svox/d" build/target/product/sdk.mk
sed -i.001 -e "/(TARGET_ARCH),arm/s/arm/armfalse/" frameworks/base/cmds/app_process/Android.mk
sed -i.001 -e "/libsqlite/d" frameworks/base/media/jni/Android.mk
gzip system/core/sh/Android.mk
gzip sdk/emulator/qtools/Android.mk
sed -i.001 -e "/(LOCAL_PATH)\/ndk\/Android.mk/d" prebuilts/Android.mk
sed -i.001 -e "/^\$(LOCAL_INSTALLED_MODULE):/d" build/core/binary.mk
sed -i.001 -e "/^include/d" build/core/host_java_library.mk
sed -i.001 -e "/^include/d" build/core/java.mk
sed -i.001 -e "/^service zygote/a \ \ \ \ disabled" \
    -e "\$r '$(dirname $0)'/../data/new_init.txt"  system/core/rootdir/init.rc
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

# remove unnecessary emulator tests which cause build problems
sed -i.001 -e "/translator_tests\/GLES/d" sdk/emulator/opengl/Android.mk

#[ -e vendor ] || ln -s vendor_extra vendor
if [ -e vendor ] ; then
	VENDOR_DIR="vendor"
elif [ -e vendor_extra ] ; then
	VENDOR_DIR=vendor_extra
fi

# QCOM
if [ -e $VENDOR_DIR/qcom/proprietary ] ; then
    ln -s ../../$VENDOR_DIR/qcom/proprietary vendor/qcom/proprietary
    sed -i.001 -e "/BOARD_USE_QCOM_LLVM_CLANG_RS/d" device/qcom/*/BoardConfig.mk
    sed -i.001 -e "/llvm-select.mk/d" device/qcom/common/common.mk
    sed -i.001 \
        -e "/^LOCAL_MODULE_SUFFIX.*.apk/,/BUILD_PREBUILT/s/^/#/" \
        -e "/^LOCAL_MODULE_SUFFIX.*(COMMON_JAVA_PACKAGE_SUFFIX)/,/BUILD_PREBUILT/s/^/#/" \
        $VENDOR_DIR/qcom/proprietary/prebuilt_HY11/target/product/*/Android.mk
    if [ -e $VENDOR_DIR/qcom/proprietary/clang-rs ] ; then
        gzip $VENDOR_DIR/qcom/proprietary/clang-rs/clang-host-build.mk
        find $VENDOR_DIR/qcom/proprietary/clang-rs/ -name Android.mk -exec gzip {} \;
    fi

    if [ -e $VENDOR_DIR/qcom/proprietary/flash10-bin ] ; then
        ls $VENDOR_DIR/qcom/proprietary/flash10-bin/*/Android.mk | while read filename ; do
            gzip $filename
        done
    fi
    [ -f $VENDOR_DIR/qcom/proprietary/neocore/Android.mk ] && gzip $VENDOR_DIR/qcom/proprietary/neocore/Android.mk
    [ -f device/qcom/common/generate_extra_images.mk ] && \
        sed -i.001 -e "/^RECOVERY_FROM_BOOT_PATCH/d" device/qcom/common/generate_extra_images.mk
    [ -f $VENDOR_DIR/qcom/proprietary/mm-http/Android.mk ] && \
        sed -i.001 -e "/include/d" $VENDOR_DIR/qcom/proprietary/mm-http/Android.mk
    [ -e prebuilts/ndk ] && (cd prebuilts/ndk; ln -s ../../prebuilts/ndk/* .)
    # 2.3.6
    [ -f $VENDOR_DIR/qcom/proprietary/common/build/vendorsetup.sh ] && \
        chmod a+x $VENDOR_DIR/qcom/proprietary/common/build/vendorsetup.sh
    sed -i.001 -e "s/ ndk\// prebuilts\/ndk\/android-ndk-r6\//" $VENDOR_DIR/qcom/proprietary/wfd/rtsp/Android.mk
    sed -i.001 -e "/FEATURE_GSIFF_ANDROID_NDK = 1/d" $VENDOR_DIR/qcom/proprietary/gps/isagnav/gsiff/Android.mk
    gzip $VENDOR_DIR/qcom/proprietary/wfd/wdsm/service/jni/Android.mk
    sed -i.001 -e "/\.apk/s/^/#/" $VENDOR_DIR/qcom/proprietary/common/config/device-vendor.mk
fi

THISVER="$(make -f "$(dirname $0)"/../data/printvar.mk PLATFORM_VERSION)"

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

    sed -i.001 -e "/libjavacore/d" build/target/product/core.mk
    sed -i.001 -e "/libjavacore/d" build/target/product/mini.mk
    sed -i.001 \
    -e "/WITH_HOST_DALVIK/,/endif/s/^/#/" \
    build/core/product_config.mk
    
    if [ -e device/qcom/common/generate_extra_images.mk ] ; then
    sed -i.001 -e "/boot.img.secure/d" device/qcom/common/generate_extra_images.mk
    fi
    
    if [ -e device/qcom/common/common.mk ] ; then
    sed -i.001 -e "/LivePicker/d" device/qcom/common/common.mk
    fi


    gzip frameworks/av/media/libstagefright/chromium_http/Android.mk
    sed -i.001 -e "/^droidcore: /s/doc-comment-check-docs//" frameworks/base/Android.mk
    sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/av/media/libstagefright/Android.mk
    sed -i.001 -e "/^include external\/junit\/Common.mk/d" frameworks/base/Android.mk
    sed -i.001 -e "/libcore\/Docs.mk/d" frameworks/base/Android.mk
    sed -i.001 -e "/libcore_to_document\/Docs.mk/d" frameworks/base/Android.mk
    sed -i.001 -e "/^ifneq (\$(TARGET_BUILD_PDK), true)/s/\$(TARGET_BUILD_PDK)/true/" frameworks/av/media/libstagefright/Android.mk

    gzip frameworks/base/services/jni/Android.mk

    #QCOM
    if [ -e $VENDOR_DIR/qcom/proprietary ] ; then
        [ -f $VENDOR_DIR/qcom/opensource/bt-wlan-coex/btc/wlan_btc_usr_svc.c ] && \
            sed -i.001 -e "s/ LOGI/ ALOGI/" -e "s/ LOGE/ ALOGE/" -e "s/ LOG_FATAL/ ALOG_FATAL/" \
            $VENDOR_DIR/qcom/opensource/bt-wlan-coex/btc/wlan_btc_usr_svc.c
        [ -f $VENDOR_DIR/qcom/opensource/bt-wlan-coex/btces/btces_plat.h ] && \
            sed -i.001 -e "s/ LOGI/ ALOGI/" -e "s/ LOGE/ ALOGE/" -e "s/ LOG_FATAL/ ALOG_FATAL/" \
            $VENDOR_DIR/qcom/opensource/bt-wlan-coex/btces/btces_plat.h
    fi
    sed -i.001  's:^\(\s*packages/[^)]*$\):#\1:g' device/*/*/device_base.mk
    ;;
4.2)
    sed -i.001 -e "/^include .*llvm_config.mk/d" build/core/config.mk
    sed -i.001 -e "/^LOCAL_CLANG := true/d" external/libpng/Android.mk
    echo "#############################################################################"
    echo "THISVER is 4.2"
    echo "#############################################################################"

    sed -i.001 -e "/libjavacore/d" build/target/product/core.mk
    sed -i.001 -e "/libjavacore/d" build/target/product/mini.mk
    sed -i.001 \
        -e "/WITH_HOST_DALVIK/,/endif/s/^/#/" \
        build/core/product_config.mk

    if [ -e device/qcom/common/generate_extra_images.mk ] ; then
        sed -i.001 -e "/boot.img.secure/d" device/qcom/common/generate_extra_images.mk
    fi

    if [ -e device/qcom/common/common.mk ] ; then
        sed -i.001 -e "/LivePicker/d" device/qcom/common/common.mk
    fi


    gzip frameworks/av/media/libstagefright/chromium_http/Android.mk
    sed -i.001 -e "/^droidcore: /s/doc-comment-check-docs//" frameworks/base/Android.mk
    sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/av/media/libstagefright/Android.mk
    sed -i.001 -e "/^include external\/junit\/Common.mk/d" frameworks/base/Android.mk
    sed -i.001 -e "/libcore\/Docs.mk/d" frameworks/base/Android.mk
    sed -i.001 -e "/libcore_to_document\/Docs.mk/d" frameworks/base/Android.mk
    sed -i.001 -e "/^ifneq (\$(TARGET_BUILD_PDK), true)/s/\$(TARGET_BUILD_PDK)/true/" frameworks/av/media/libstagefright/Android.mk

    gzip frameworks/base/services/jni/Android.mk

    sed -i.001 -e "/\$(BUILD_TINY_ANDROID), true)/,/\endif/d" system/core/debuggerd/Android.mk
    gzip frameworks/base/drm/jni/Android.mk
    sed -i.001 -e "s/ prebuilts\/ndk\/android-ndk-r6\// prebuilts\/ndk\/6\//" $VENDOR_DIR/qcom/proprietary/wfd/rtsp/Android.mk

    if [ -e external/mobicore/Android.mk ] ; then
        sed -i.001 -e "/rootpa\/Code\/Android\/app\/jni\/Android.mk/d" external/mobicore/Android.mk
    fi
    sed -i.001 -e "/E2FSCK/s/^/#/" build/core/config.mk

    ;;
esac

touch .fixup_applied
