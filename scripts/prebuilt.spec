
#Name: android_%{_android_platform}_%{_android_product}
Name: android_%{_android_platform}
Version: 1
Release: 1
License: GPL
Summary: prebuilt stuff
%description
Package up the results of an android source build

%install
#PRODUCT_DIR=out/target/product/%{_android_product}
PRODUCT_DIR=${ANDROID_PRODUCT_OUT#$ANDROID_BUILD_TOP/}
find frameworks/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >temp_filelist
find external/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find dalvik/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find hardware/ -name "*.mk" -o -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find device/ -name "*.mk" -o -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find build/ -type f >>temp_filelist
find . -name vendorsetup.sh >>temp_filelist
echo "$PRODUCT_DIR/obj/lib" >>temp_filelist
echo "$PRODUCT_DIR/obj/include" >>temp_filelist
ls -d frameworks/*/build >>temp_filelist
fgrep -v Android.mk temp_filelist | fgrep -v " " | fgrep -v /stlport/ >devel_filelist
find $PRODUCT_DIR -name \*.a >devel_static_filelist
cp prebuilt/.git/config prebuilt/git.config
cp prebuilt/.git/HEAD prebuilt/git.HEAD
$SCRIPT_DIR/update.py $PRODUCT_DIR/system/bin/linker $PRODUCT_DIR/system/bin/linker.chroot

dirname $ANDROID_TOOLCHAIN | sed -e "s/.*prebuilt/\/aroot\/prebuilt/" > compiler_filelist
cat compiler_filelist
echo "$PRODUCT_DIR/root" >targetroot_filelist
echo "$PRODUCT_DIR/system" >>targetroot_filelist
echo "$PRODUCT_DIR/data" >>targetroot_filelist
echo "$PRODUCT_DIR/kernel" >>targetroot_filelist

echo "$PRODUCT_DIR/symbols" >targetroot_debug_filelist
ls $PRODUCT_DIR/*.txt $PRODUCT_DIR/*.img >image_filelist
find . -name .git | fgrep -v .repo | sed -e "s/.*/&\/config\n&\/HEAD/" >git_filelist

mkdir -p $RPM_BUILD_ROOT/aroot
ln -s `pwd`/* $RPM_BUILD_ROOT/aroot
rm -f $RPM_BUILD_ROOT/aroot/tmp
rm $RPM_BUILD_ROOT/aroot/Makefile $RPM_BUILD_ROOT/aroot/build
tar czfh $RPM_BUILD_ROOT/aroot/git_files.tgz `cat git_filelist`

cp Makefile $RPM_BUILD_ROOT/aroot/
tar cf - build | (cd $RPM_BUILD_ROOT/aroot; tar xf -)

sed -i.001 -e "s/^/\/aroot\//" image_filelist
sed -i.001 -e "s/^/\/aroot\//" devel_filelist
sed -i.001 -e "s/^/\/aroot\//" devel_static_filelist
sed -i.001 -e "s/^/\/aroot\//" targetroot_filelist
sed -i.001 -e "s/^/\/aroot\//" targetroot_debug_filelist

cd $RPM_BUILD_ROOT/aroot
pwd
sed -f $SCRIPT_DIR/sed/no_product_copy.sed <$RPM_BUILD_DIR/build/core/Makefile >build/core/Makefile

# if we are not running on a stripped sysroot, we need to 
# add a null.mk to dalvik.  No effect on the full build but it
# would be better if the stripped makerules added this dynamically
if [ ! -e dalvik/null.mk ]; then
    touch dalvik/null.mk
fi



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
#this moved from frameworks/base to frameworks/native in 4.1.1
ln -s ../../frameworks/*/opengl/include/* .
ln -s ../../dalvik/libnativehelper/include/nativehelper/jni.h .
ln -s ../../external/zlib/zlib.h ../../external/zlib/zconf.h .
ln -s ../../system/core/include/pixelflinger .
ln -s ../../system/core/include/system .
ln -s ../../system/core/include/cutils .

case  "%{_android_platform}" in 
	"2.3.7") 
	ln -s ../../frameworks/base/include/gui .
	ln -s ../../frameworks/base/include/surfaceflinger .
	ln -s ../../frameworks/base/include/binder .
	ln -s ../../frameworks/base/include/utils .	
	ln -s ../../frameworks/base/include/ui .
        ln -s ../../frameworks/base/include/media .
	;;
	"4.0.4") 
	ln -s ../../frameworks/base/include/gui .
	ln -s ../../frameworks/base/include/surfaceflinger .
	ln -s ../../frameworks/base/include/binder .
	ln -s ../../frameworks/base/include/utils .	
	ln -s ../../frameworks/base/include/ui .
        ln -s ../../frameworks/base/include/media .
	;;
	"4.1.1") 
        # they moved the surfaceflinger include files to gui
	ln -s ../../frameworks/native/include/gui .
	ln -s ../../frameworks/native/include/gui surfaceflinger
	ln -s ../../frameworks/native/include/binder .
	ln -s ../../frameworks/native/include/utils .
	ln -s ../../frameworks/native/include/ui .
        ln -s ../../frameworks/av/include/media .
	;;
    *)
	echo "if you get here you probably need to add another version case"
	;;
esac
ln -s ../../hardware/libhardware/include/hardware .
ln -s ../../hardware/libhardware_legacy/include/hardware_legacy .
ln -s ../../hardware/ril/include/telephony .
ln -s ../../bionic .
ln -s ../../external/stlport/stlport .
# this may or may not exist
if [ -d ../../external/bionicsf-services/include ]; then
    ln -s ../../external/bionicsf-services/include/* .
fi


(cd android; ln -s `ls ../../../bionic/libc/include/android/* ../../../frameworks/base/native/include/android/* ../../../frameworks/native/include/android/* ../../../system/core/include/android/log.h 2>/dev/null` .)
cd ../lib
ln -s ../../$PRODUCT_DIR/obj/lib/*.o .
ln -s ../../$PRODUCT_DIR/obj/lib/libandroid.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libc.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libdl.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libEGL.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libGLESv1_CM.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libGLESv2.so .
#no longer built ln -s ../../$PRODUCT_DIR/obj/lib/libjnigraphics.so .
ln -s ../../$PRODUCT_DIR/obj/lib/liblog.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libm.so .
#not in 2.3.7 ln -s ../../$PRODUCT_DIR/obj/lib/libOpenMAXAL.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libOpenSLES.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libstdc++.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libthread_db.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libz.so .
ln -s ../../$PRODUCT_DIR/obj/STATIC_LIBRARIES/libc_intermediates/libc.a .
ln -s ../../$PRODUCT_DIR/obj/STATIC_LIBRARIES/libm_intermediates/libm.a .
ln -s ../../$PRODUCT_DIR/obj/STATIC_LIBRARIES/libstdc++_intermediates/libstdc++.a .
ln -s ../../$PRODUCT_DIR/obj/lib/libutils.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libgui.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libstlport.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libbinder.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libcutils.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libhardware.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libhardware_legacy.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libinput.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libmedia.so .
ln -s ../../$PRODUCT_DIR/obj/lib/libsigyn.so .

cd ../..
mkdir -p toolchain
cd toolchain
TC_TMP=`dirname $TOOLPREFIX`
TC_DIR=`dirname $TC_TMP`
echo TC_DIR $TC_DIR
TOOL_DIRNAME=`basename ${TOOLPREFIX%\-}`

ln -s ../${TC_DIR}/$TOOL_DIRNAME .
ln -s ../${TC_DIR}/include .
ln -s ../${TC_DIR}/lib .
ln -s ../${TC_DIR}/lib32 .
ln -s ../${TC_DIR}/libexec .
ln -s ../${TC_DIR}/share .
mkdir bin
# we want a consistent name for the toolchain.
cd bin
for i in addr2line ar as c++ c++filt cpp elfedit g++ gcc gcc-4.6.x-google gcov gdb gdbtui gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf run size strings strip; do
    [ -e ../../${TOOLPREFIX}$i ] && ln -s ../../${TOOLPREFIX}$i arm-bionic-eabi-$i;
done

cd ..
GCC_SPEC_DIR=`bin/arm-bionic-eabi-gcc -print-search-dirs | fgrep install: | sed -e "s/install: //"`
cp $SCRIPT_DIR/gcc_sysroot.specs $GCC_SPEC_DIR/specs
ln -s $GCC_SPEC_DIR/specs .
mkdir -p libgcc-arm
cd libgcc-arm
ln -s `ls ../../${TC_DIR}/lib/gcc/$TOOL_DIRNAME/*/android/libgcc.a ../../${TC_DIR}/lib/gcc/$TOOL_DIRNAME/*/armv7-a/libgcc.a 2>/dev/null` .

%package toolchain
BuildArch: noarch
Summary: gcc cross compiler and /usr/include, /usr/lib
AutoReqProv: 0
%description toolchain
The 'toolchain' package contains the prebuilt gcc compiler and binutils toolchain.
%files toolchain -f compiler_filelist
/aroot/prebuilt/android-arm
/aroot/prebuilt/git.*
/aroot/toolchain

%package %{_android_product}_image
BuildArch: noarch
Summary: Output flash images
AutoReqProv: 0
%description %{_android_product}_image
The 'image' package contains the *.img files that can be
directly flashed to a device.
%files %{_android_product}_image -f image_filelist

%package %{_android_product}_devel_static
BuildArch: noarch
Summary: library archive files
AutoReqProv: 0
%description %{_android_product}_devel_static
The 'devel_static' package contains the *.a libraries that 
are used to build some source packages.
%files %{_android_product}_devel_static -f devel_static_filelist

%package %{_android_product}_targetroot
BuildArch: noarch
Summary: library archive files
AutoReqProv: 0
%description %{_android_product}_targetroot
The 'targetroot' package contains the system, root, etc
directories from the target image, allowing regeneration
of the *.img files
%files %{_android_product}_targetroot -f targetroot_filelist

%package %{_android_product}_targetroot_debug
BuildArch: noarch
Summary: library archive files
AutoReqProv: 0
%description %{_android_product}_targetroot_debug
The 'targetroot' package contains the system, root, etc
directories from the target image, allowing regeneration
of the *.img files
%files %{_android_product}_targetroot_debug -f targetroot_debug_filelist

%package %{_android_product}_devel
BuildArch: noarch
Summary: /usr/lib
AutoReqProv: 0
%description %{_android_product}_devel
The 'devel' package contains the headers, libraries and build scripts
needed to compile other source packages.  (but not the compiler)
%files %{_android_product}_devel -f devel_filelist
/aroot/usr
/aroot/bionic/lib*/include
/aroot/bionic/libc/arch-*/include
/aroot/bionic/libc/kernel/common
/aroot/bionic/libc/kernel/arch-*
/aroot/Makefile
/aroot/dalvik/null.mk
/aroot/system/core/include
/aroot/external/stlport/stlport
/aroot/out/host/linux-x86/bin
/aroot/device/sample/skins
/aroot/git_files.tgz
