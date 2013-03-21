#
set -x
set -e
if [ -z "$1" -o -z "$2" ] ; then
    echo "compileqt.sh <version> <product>"
    exit -1
fi
#~/klaatu-manifests/scripts/compileqt.sh android-4.0.4_r1.2 maguro
#~/klaatu-manifests/scripts/compileqt.sh android-4.1.2_r1 grouper
#~/klaatu-manifests/scripts/compileqt.sh android-4.1.2_r1 maguro
#~/klaatu-manifests/scripts/compileqt.sh android-4.2.1_r1.2 grouper
#~/klaatu-manifests/scripts/compileqt.sh android-4.2.1_r1.2 maguro

~/klaatu-manifests/scripts/fullbuild $1 default.xml ~/klaatu-manifests/manifests/qt_2012-05-30-withdemo.xml
#~/klaatu-manifests/scripts/fullbuild $1 default.xml ~/klaatu-manifests/manifests/qt_2012-05-30-withdemo-4.2.xml
source ./build/envsetup.sh; lunch full_$2-userdebug
make -j 30
make -j 30
make -j 30
