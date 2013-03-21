#
repo init -u git://gitorious.org/rowboat/manifest.git -m rowboat-jb-am37x.xml
repo sync
export PATH=~/android44/prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin:$PATH
make TARGET_PRODUCT=beagleboard droid
make TARGET_PRODUCT=beagleboard fs_tarball
