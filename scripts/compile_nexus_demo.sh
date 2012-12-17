#
set -x
set -e
#repo init -u https://android.googlesource.com//platform/manifest -b android-4.1.2_r1
#ln -s ~/klaatu-manifests/manifests/qt_2012-05-30-withdemo.xml .repo/local_manifest.xml
#repo sync
~/klaatu-manifests/scripts/fullbuild android-4.1.2_r1 default.xml ~/klaatu-manifests/manifests/qt_2012-05-30-withdemo.xml
# ~/klaatu-manifests/manifests/sio2_demo.xml
source ./build/envsetup.sh; lunch full_maguro-userdebug
make -j 30
make -j 30
