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
    -e "/find-jdk-tools-jar.sh/,/endif/{s/:=.*/:=/;tx;d;:x}" \
    -e "/BUILD_DROIDDOC:=/s/BUILD_SYSTEM)\/droiddoc/TOPDIR)dalvik\/null/" build/core/config.mk
sed -i.001 -e "s/(.*java_version))/(true/" -e "s/(.*javac_version))/(true/" build/core/main.mk

#set TARGET_NO_RECOVERY=true as the default
sed -i.001 -e "s/\$(TARGET_NO_RECOVERY)/true/" build/core/Makefile 
if [ -e device/qcom/common/common.mk ] ; then
    # llvm config in device/qcom????
    sed -i.001 -e "/llvm-select.mk/s/^/#/" device/qcom/common/common.mk
fi

# these perform local modifications to frameworks/base
sed -i.001 -e "s/android-logo-mask.png/cambridge-logo-mask.png/" frameworks/base/cmds/bootanimation/BootAnimation.cpp
sed -i.001 -e "/simphonebook\" },/s/}/},\n    { AID_RADIO, \"sigyn\" }/" frameworks/base/cmds/servicemanager/service_manager.c
