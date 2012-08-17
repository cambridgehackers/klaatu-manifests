#
gzip frameworks/base/media/libstagefright/chromium_http/Android.mk
gzip system/media/wilhelm/tests/native-media/jni/Android.mk
gzip system/media/mca/filterfw/jni/Android.mk
sed -i.001 -e "/^LOCAL_WHOLE_STATIC_LIBRARIES := /s/libfilterfw_jni//" -e "/libjnigraphics/d" system/media/mca/filterfw/Android.mk
