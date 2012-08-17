#
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
gzip frameworks/base/cmds/app_process/Android.mk
gzip frameworks/base/native/android/Android.mk
gzip system/core/sh/Android.mk
sed -i.001 -e "/(LOCAL_PATH)\/[sn]dk\/Android.mk/d" prebuilt/Android.mk
sed -i.001 -e "/^\$(LOCAL_INSTALLED_MODULE):/d" build/core/binary.mk
sed -i.001 -e "/^include/d" build/core/host_java_library.mk
sed -i.001 -e "/^include/d" build/core/java.mk
sed -i.001 -e "/^service zygote/s/^/service powermanager \/system\/bin\/powermanager\n    class main\n    user system\n    group system\n\n/" -e "/^service zygote/,+6d" system/core/rootdir/init.rc
sed -i.001 -e "/com_android_server_InputManager.cpp/d"  -e "/com_android_server_InputWindowHandle.cpp/d" \
    -e "/onload.cpp/d" -e "/com_android_server_input_InputManagerService.cpp/d" \
    -e "/com_android_server_input_InputWindowHandle.cpp/d" \
    -e "/com_android_server_PowerManagerService.cpp/d" -e "/com_android_server_UsbDeviceManager.cpp/d" \
    -e "/com_android_server_UsbHostManager.cpp/d" -e "/com_android_server_location_GpsLocationProvider.cpp/d" \
    frameworks/base/services/jni/Android.mk
sed -i.001 -e "/BUILD_HOST_PREBUILT:=/s/BUILD_SYSTEM)\/host_prebuilt/TOPDIR)dalvik\/null/" \
    -e "/BUILD_JAVA_LIBRARY:=/s/BUILD_SYSTEM)\/java_library/TOPDIR)dalvik\/null/" \
    -e "/BUILD_DROIDDOC:=/s/BUILD_SYSTEM)\/droiddoc/TOPDIR)dalvik\/null/" build/core/config.mk
#
sed -i.001 -e "s/android-logo-mask.png/cambridge-logo-mask.png/" frameworks/base/cmds/bootanimation/BootAnimation.cpp
sed -i.001 -e "/simphonebook\" },/s/}/},\n    { AID_RADIO, \"sigyn\" }/" frameworks/base/cmds/servicemanager/service_manager.c