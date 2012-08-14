
Name: android
Version: 1
Release: 2.3.7_r1
License: GPL
Summary: prebuilt stuff

%description

%install
PRODUCT_DIR=out/target/product/crespo
find frameworks/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >temp_filelist
find external/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find dalvik/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find hardware/ -name "*.mk" -o -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find device/ -name "*.mk" -o -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find build/ -type f >>temp_filelist
find . -name vendorsetup.sh >>temp_filelist
find out/target -name \*.a >>temp_filelist
printf "$PRODUCT_DIR/obj/lib\n$PRODUCT_DIR/system\n$PRODUCT_DIR/symbols\n$PRODUCT_DIR/obj/include\n" >>temp_filelist
fgrep -v Android.mk temp_filelist | fgrep -v " " | fgrep -v /stlport/ | sed -e "s/^/\/aroot\//" >output_filelist
cp prebuilt/.git/config prebuilt/git.config
cp prebuilt/.git/HEAD prebuilt/git.HEAD
$SCRIPT_DIR/update.py $PRODUCT_DIR/system/bin/linker $PRODUCT_DIR/system/bin/linker.chroot

mkdir -p $RPM_BUILD_ROOT/aroot
ln -s `pwd`/* $RPM_BUILD_ROOT/aroot
rm $RPM_BUILD_ROOT/aroot/Makefile $RPM_BUILD_ROOT/aroot/build

cp Makefile $RPM_BUILD_ROOT/aroot/
tar cf - build | (cd $RPM_BUILD_ROOT/aroot; tar xf -)
cd $RPM_BUILD_ROOT/aroot
pwd
patch -p0 <$SCRIPT_DIR/patch.no_product_copy
mkdir -p usr/include usr/lib
cd usr/include/
ln -s ../../bionic/libc/include/* .
rm -f android
mkdir android
ln -s ../../bionic/libc/kernel/arch-arm/asm/ .
ln -s ../../bionic/libc/kernel/common/asm-generic/ .
ln -s ../../bionic/libc/kernel/common/linux/ .
ln -s ../../bionic/libc/kernel/common/mtd/ .
ln -s ../../bionic/libthread_db/include/thread_db.h .
ln -s ../../bionic/libm/include/*.h .
ln -s ../../bionic/libm/include/arm/*.h .
ln -s ../../bionic/libc/arch-arm/include/machine/ .
ln -s ../../frameworks/base/opengl/include/* .
ln -s ../../dalvik/libnativehelper/include/nativehelper/jni.h .
ln -s ../../external/zlib/zlib.h ../external/zlib/zconf.h .
(cd android; ln -s ../../../bionic/libc/include/android/* ../../../frameworks/base/native/include/android/* ../../../system/core/include/android/log.h .)
cd ../lib
ln -s ../../$PRODUCT_DIR/obj/lib/*.o .
ln -s ../../$PRODUCT_DIR/obj/lib/libandroid.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libc.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libdl.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libEGL.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libGLESv1_CM.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libGLESv2.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libjnigraphics.so .
ln -s ../../$PRODUCT_DIR/obj/lib/liblog.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libm.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libOpenMAXAL.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libOpenSLES.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libstdc++.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libthread_db.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libz.so .
ln -s ../../$PRODUCT_DIR/obj/STATIC_LIBRARIES/libc_intermediates/libc.a .
ln -s ../../$PRODUCT_DIR/obj/STATIC_LIBRARIES/libm_intermediates/libm.a .
ln -s ../../$PRODUCT_DIR/obj/STATIC_LIBRARIES/libstdc++_intermediates/libstdc++.a .

%package gcc
BuildArch: noarch
Summary: gcc cross compiler and /usr/include, /usr/lib
AutoReqProv: 0

%description gcc

%files gcc
#/aroot/prebuilt/linux-x86/toolchain/arm-linux-androideabi-4.6
/aroot/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3
/aroot/prebuilt/android-arm
/aroot/prebuilt/git.*

%package sysroot
BuildArch: noarch
Summary: /usr/lib
AutoReqProv: 0

%description sysroot

%files sysroot -f output_filelist
/aroot/usr
/aroot/bionic/lib*/include
/aroot/bionic/libc/arch-*/include
/aroot/bionic/libc/kernel/common
/aroot/bionic/libc/kernel/arch-*
/aroot/Makefile
/aroot/dalvik/null.mk
/aroot/system/core/include
/aroot/external/stlport/stlport
/aroot/frameworks/base/build
/aroot/out/host/linux-x86/bin
/aroot/device/sample/skins