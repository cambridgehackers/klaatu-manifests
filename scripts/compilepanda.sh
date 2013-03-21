#
set -x
set -e
repo init -u https://android.googlesource.com//platform/manifest -b master -m default.xml
ln -s ~/klaatu-manifests/manifests/panda.xml .repo/local_manifest.xml
repo sync
gzip external/klaatu-openal-soft/android/jni/Android.mk

source build/envsetup.sh; lunch full_panda-userdebug
make -j33
