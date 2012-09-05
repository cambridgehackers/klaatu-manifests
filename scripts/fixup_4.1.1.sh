#!/bin/bash
gzip frameworks/av/media/libstagefright/chromium_http/Android.mk
gzip frameworks/wilhelm/tests/native-media/jni/Android.mk
gzip frameworks/base/media/mca/filterfw/jni/Android.mk
sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/av/media/libstagefright/Android.mk
sed -i.001 -e "/^include external\/junit\/Common.mk/d" frameworks/base/Android.mk
sed -i.001 -e "/^LOCAL_WHOLE_STATIC_LIBRARIES := /s/libfilterfw_jni//" -e "/libjnigraphics/d" frameworks/base/media/mca/filterfw/Android.mk
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
#bash bug: don't end the file with a conditional
true
