#
mkdir libnativehelper
ln -s ../dalvik/libnativehelper/include libnativehelper/
gzip frameworks/base/core/jni/Android.mk
gzip frameworks/base/media/jni/Android.mk
gzip frameworks/base/media/jni/*/Android.mk
gzip frameworks/base/native/graphics/jni/Android.mk
gzip frameworks/base/tests/BrowserTestPlugin/jni/Android.mk
gzip frameworks/base/tools/layoutlib/Android.mk
gzip hardware/ril/mock-ril/Android.mk
gzip frameworks/base/graphics/jni/Android.mk
gzip frameworks/base/data/fonts/Android.mk
gzip build/core/tasks/apicheck.mk
gzip build/tools/apicheck/Android.mk
sed -i.001 -e "/^include.*external\/svox/d" build/target/product/sdk.mk
gzip frameworks/base/cmds/app_process/Android.mk
gzip frameworks/base/native/android/Android.mk
gzip system/core/sh/Android.mk
sed -i.001 -e "/(LOCAL_PATH)\/[sn]dk\/Android.mk/d" prebuilt/Android.mk
sed -i.001 -e "/^\$(LOCAL_INSTALLED_MODULE):/d" build/core/binary.mk
sed -i.001 -e "/^include/d" build/core/host_java_library.mk
sed -i.001 -e "/^include/d" build/core/java.mk
sed -i.001 -e "/^service zygote/,/restart netd/{s/^service zygote.*/service powermanager \/system\/bin\/powermanager\n    class main \n    user system \n    group system \n  \n/;/^ /d}" system/core/rootdir/init.rc
sed -i.001 -e "/com_android_server_InputManager.cpp/d"  -e "/com_android_server_InputWindowHandle.cpp/d" \
    -e "/onload.cpp/d" -e "/com_android_server_input_InputManagerService.cpp/d" \
    -e "/com_android_server_input_InputWindowHandle.cpp/d" \
    -e "/com_android_server_PowerManagerService.cpp/d" -e "/com_android_server_UsbDeviceManager.cpp/d" \
    -e "/com_android_server_UsbHostManager.cpp/d" -e "/com_android_server_location_GpsLocationProvider.cpp/d" \
    frameworks/base/services/jni/Android.mk
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

# these perform local modifications to frameworks/base
sed -i.001 -e "s/android-logo-mask.png/cambridge-logo-mask.png/" frameworks/base/cmds/bootanimation/BootAnimation.cpp
sed -i.001 -e "/simphonebook\" },/s/}/},\n    { AID_RADIO, \"sigyn\" }/" frameworks/base/cmds/servicemanager/service_manager.c

[ -e vendor ] || ln -s vendor_extra vendor

# QCOM
if [ -e vendor_extra/qcom/proprietary ] ; then
    ln -s ../../vendor_extra/qcom/proprietary vendor/qcom/proprietary
    sed -i.001 -e "/BOARD_USE_QCOM_LLVM_CLANG_RS/d" device/qcom/msm8960/BoardConfig.mk
    sed -i.001 -e "/llvm-select.mk/d" device/qcom/common/common.mk
    sed -i.001 -e "/\.apk/s/^/#/" vendor_extra/qcom/proprietary/common/config/device-vendor.mk
    sed -i.001 \
        -e "/^LOCAL_MODULE_SUFFIX.*.apk/,/BUILD_PREBUILT/s/^/#/" \
        -e "/^LOCAL_MODULE_SUFFIX.*(COMMON_JAVA_PACKAGE_SUFFIX)/,/BUILD_PREBUILT/s/^/#/" \
        vendor_extra/qcom/proprietary/prebuilt_HY11/target/product/msm8960/Android.mk
    if [ -e vendor_extra/qcom/proprietary/flash10-bin ] ; then
        ls vendor_extra/qcom/proprietary/flash10-bin/*/Android.mk | while read filename ; do
            gzip $filename
        done
    fi
    [ -f vendor_extra/qcom/proprietary/neocore/Android.mk ] && gzip vendor_extra/qcom/proprietary/neocore/Android.mk
    gzip vendor_extra/qcom/proprietary/wfd/wdsm/service/jni/Android.mk
    sed -i.001 -e "s/ ndk\// prebuilt\/ndk\/android-ndk-r6\//" vendor_extra/qcom/proprietary/wfd/rtsp/Android.mk
    sed -i.001 -e "/FEATURE_GSIFF_ANDROID_NDK = 1/d" vendor_extra/qcom/proprietary/gps/isagnav/gsiff/Android.mk
    if [ -e vendor_extra/qcom/proprietary/clang-rs ] ; then
        gzip vendor_extra/qcom/proprietary/clang-rs/clang-host-build.mk
        find vendor_extra/qcom/proprietary/clang-rs/ -name Android.mk -exec gzip {} \;
    fi
    [ -f vendor/qcom/opensource/bt-wlan-coex/btc/wlan_btc_usr_svc.c ] && \
        sed -i.001 -e "s/ LOGI/ ALOGI/" -e "s/ LOGE/ ALOGE/" -e "s/ LOG_FATAL/ ALOG_FATAL/" \
        vendor/qcom/opensource/bt-wlan-coex/btc/wlan_btc_usr_svc.c
    [ -f vendor/qcom/opensource/bt-wlan-coex/btces/btces_plat.h ] && \
        sed -i.001 -e "s/ LOGI/ ALOGI/" -e "s/ LOGE/ ALOGE/" -e "s/ LOG_FATAL/ ALOG_FATAL/" \
        vendor/qcom/opensource/bt-wlan-coex/btces/btces_plat.h
    sed -i.001 -e "/^RECOVERY_FROM_BOOT_PATCH/d" device/qcom/common/generate_extra_images.mk
    sed -i.001 -e "/include/d" vendor_extra/qcom/proprietary/mm-http/Android.mk
    (cd prebuilt/ndk; ln -s ../../prebuilts/ndk/* .)
    # 2.3.6
    #[ -f vendor/qcom/android-open/libopencorehw/Android.mk ] && gzip vendor/qcom/android-open/libopencorehw/Android.mk
    chmod a+x vendor/qcom/proprietary/common/build/vendorsetup.sh
#sed -i.001 -e "s/external\/opencore\/extern_libs_v2\/khronos\/openmax\/include/vendor\/qcom\/opensource\/omx\/mm-core\/omxcore\/inc/" vendor/qcom/proprietary/mm-video/DivxDrmDecrypt/Android.mk
fi
