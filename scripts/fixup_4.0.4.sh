#
gzip frameworks/base/libs/rs/Android.mk
gzip frameworks/base/media/libstagefright/chromium_http/Android.mk
gzip system/media/wilhelm/tests/native-media/jni/Android.mk
gzip system/media/mca/filterfw/jni/Android.mk
sed -i.001 -e "/^LOCAL_WHOLE_STATIC_LIBRARIES := /s/libfilterfw_jni//" -e "/libjnigraphics/d" system/media/mca/filterfw/Android.mk
sed -i.001 -e "/^bool checkPermission(/,/^{/ {/^{/s/$/\n    \/\/ For now, we'll always allow root programs to have permission\n    if (uid == 0)\n        return true;\n\n/}" frameworks/base/libs/binder/IServiceManager.cpp
sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/base/media/libstagefright/Android.mk
