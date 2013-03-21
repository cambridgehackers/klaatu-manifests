#
set -x
set -e
repo init -u https://github.com/cambridgehackers/zynq-android4 -b jb -m xylon.xml
repo sync
source build/envsetup.sh; lunch zedboard-userdebug
make -j33
#make -j33 userdataimage-nodeps systemimage-nodeps
