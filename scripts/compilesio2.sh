#
set -x
set -e
~/klaatu-manifests/scripts/fullbuild android-4.1.1_r3 default.xml ~/klaatu-manifests/manifests/sio2_demo.xml
source build/envsetup.sh; lunch full_maguro-userdebug
gzip external/klaatu-openal-soft/android/jni/Android.mk
make -j33
make -j33 userdataimage-nodeps systemimage-nodeps
