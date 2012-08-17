#
gzip frameworks/base/core/jni/Android.mk
gzip frameworks/base/media/jni/Android.mk
gzip frameworks/base/media/jni/*/Android.mk
gzip frameworks/base/native/graphics/jni/Android.mk
gzip frameworks/base/tests/BrowserTestPlugin/jni/Android.mk
gzip frameworks/base/tools/layoutlib/Android.mk
gzip hardware/ril/mock-ril/Android.mk
gzip system/media/mca/filterfw/jni/Android.mk
gzip frameworks/base/libs/rs/Android.mk
gzip frameworks/base/graphics/jni/Android.mk
gzip frameworks/base/data/fonts/Android.mk
gzip build/core/tasks/apicheck.mk
gzip build/tools/apicheck/Android.mk
gzip frameworks/base/cmds/app_process/Android.mk
gzip system/media/wilhelm/tests/native-media/jni/Android.mk
gzip frameworks/base/native/android/Android.mk
gzip frameworks/base/media/libstagefright/chromium_http/Android.mk
gzip system/core/sh/Android.mk
sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/base/media/libstagefright/Android.mk
sed -i.001 -e "/(LOCAL_PATH)\/[sn]dk\/Android.mk/d" prebuilt/Android.mk
sed -i.001 -e "/^\$(LOCAL_INSTALLED_MODULE):/d" build/core/binary.mk
sed -i.001 -e "/^include/d" build/core/host_java_library.mk
sed -i.001 -e "/^include/d" build/core/java.mk
sed -i.001 -e "/^service zygote/s/^/service powermanager \/system\/bin\/powermanager\n    class main\n    user system\n    group system\n\n/" -e "/^service zygote/,+6d" system/core/rootdir/init.rc
sed -i.001 -e "/com_android_server_InputManager.cpp/d"  -e "/com_android_server_InputWindowHandle.cpp/d" -e "/onload.cpp/d" frameworks/base/services/jni/Android.mk
sed -i.001 -e "/^LOCAL_WHOLE_STATIC_LIBRARIES := /s/libfilterfw_jni//" -e "/libjnigraphics/d" system/media/mca/filterfw/Android.mk
