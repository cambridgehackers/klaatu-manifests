#
gzip frameworks/base/libs/rs/Android.mk
gzip frameworks/base/media/libstagefright/chromium_http/Android.mk
gzip system/media/wilhelm/tests/native-media/jni/Android.mk
gzip system/media/mca/filterfw/jni/Android.mk
sed -i.001 -e "/^LOCAL_WHOLE_STATIC_LIBRARIES := /s/libfilterfw_jni//" -e "/libjnigraphics/d" system/media/mca/filterfw/Android.mk
sed -i.001 -e "/^bool checkPermission(/,/^{/ {/^{/s/$/\n    \/\/ For now, we'll always allow root programs to have permission\n    if (uid == 0)\n        return true;\n\n/}" frameworks/base/libs/binder/IServiceManager.cpp
sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/base/media/libstagefright/Android.mk
[ -e vendor ] || ln -s vendor_extra vendor

# QCOM
if [ -e vendor_extra/qcom/proprietary ] ; then
    ln -s ../../vendor_extra/qcom/proprietary vendor/qcom/proprietary
    [ -f device/qcom/msm8960/BoardConfig.mk ] && \
        sed -i.001 -e "/BOARD_USE_QCOM_LLVM_CLANG_RS/d" \
            device/qcom/msm8960/BoardConfig.mk
    [ -f device/qcom/common/common.mk ] && sed -i.001 -e "/llvm-select.mk/d" device/qcom/common/common.mk
    [ -f vendor_extra/qcom/proprietary/common/config/device-vendor.mk ] && sed -i.001 -e "/\.apk/s/^/#/" vendor_extra/qcom/proprietary/common/config/device-vendor.mk
    #[ -f vendor_extra/qcom/proprietary/prebuilt_HY11/target/product/msm8960/Android.mk ] && sed -i.001 -e "/\.apk/s/^/#/" vendor_extra/qcom/proprietary/prebuilt_HY11/target/product/msm8960/Android.mk
    [ -f vendor_extra/qcom/proprietary/prebuilt_HY11/target/product/msm8960/Android.mk ] && \
        sed -i.001 -e "/BUILD_PREBUILT/s/^/#/" vendor_extra/qcom/proprietary/prebuilt_HY11/target/product/msm8960/Android.mk
    ls vendor_extra/qcom/proprietary/flash10-bin/*/Android.mk | while read filename ; do
        gzip $filename
    done
    [ -f vendor_extra/qcom/proprietary/neocore/Android.mk ] && gzip vendor_extra/qcom/proprietary/neocore/Android.mk
    gzip vendor_extra/qcom/proprietary/wfd/wdsm/service/jni/Android.mk
    [ -f vendor_extra/qcom/proprietary/wfd/rtsp/Android.mk ] && \
        sed -i.001 -e "s/ ndk\// prebuilt\/ndk\/android-ndk-r6\//" vendor_extra/qcom/proprietary/wfd/rtsp/Android.mk
    [ -f vendor_extra/qcom/proprietary/gps/isagnav/gsiff/Android.mk ] && \
        sed -i.001 -e "/FEATURE_GSIFF_ANDROID_NDK = 1/d" vendor_extra/qcom/proprietary/gps/isagnav/gsiff/Android.mk
    gzip vendor_extra/qcom/proprietary/clang-rs/clang-host-build.mk
    find vendor_extra/qcom/proprietary/clang-rs/ -name Android.mk -exec gzip {} \;
    #patch -p1 <$SCRIPT_DIR/camera_m8960.patch
fi
