
#Name: android_%{_android_platform}_%{_android_product}
Name: android_%{_android_platform}
Version: 1
Release: 1
License: GPL
Summary: prebuilt stuff
%description
Package up the results of an android source build

%install
PRODUCT_DIR=%{_android_product_out}
find frameworks/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >temp_filelist
find external/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find dalvik/ -name "*.h" -o -name "*.hxx" -o -name "*.hpp" >>temp_filelist
find hardware/ -name "*.mk" -o -name "*.h" -o -name "*.hxx" -o -name "*.hpp" | fgrep -v Android.mk >>temp_filelist
find device/ -name "*.mk" -o -name "*.h" -o -name "*.hxx" -o -name "*.hpp" -o -name "*.txt" | fgrep -v Android.mk >>temp_filelist
find build/ -type f | grep -v "/tools/.*/Android.mk" >>temp_filelist
find . -name vendorsetup.sh >>temp_filelist
echo "$PRODUCT_DIR/obj/lib" >>temp_filelist
echo "$PRODUCT_DIR/obj/include" >>temp_filelist
ls -d frameworks/*/build >>temp_filelist
#fgrep -v Android.mk temp_filelist | fgrep -v " " | fgrep -v /stlport/ >devel_filelist
fgrep -v " " temp_filelist | fgrep -v /stlport/ >devel_filelist
find $PRODUCT_DIR -name \*.a >devel_static_filelist
cp prebuilt/.git/config prebuilt/git.config
cp prebuilt/.git/HEAD prebuilt/git.HEAD

dirname $ANDROID_TOOLCHAIN | sed -e "s/.*prebuilt/\/aroot\/prebuilt/" > compiler_filelist
cat compiler_filelist
echo "$PRODUCT_DIR/root" >targetroot_filelist
echo "$PRODUCT_DIR/system" >>targetroot_filelist
echo "$PRODUCT_DIR/data" >>targetroot_filelist
if test -e $PRODUCT_DIR/kernel ; then
    # can't locate for TI built yet
    echo "$PRODUCT_DIR/kernel" >>devel_filelist
fi
if test -e device/sample/skins ; then
    echo "device/sample/skins" >>devel_filelist
fi

echo "$PRODUCT_DIR/symbols" >targetroot_debug_filelist
ls $PRODUCT_DIR/*.txt $PRODUCT_DIR/*.img >image_filelist
find . -name .git | fgrep -v .repo | sed -e "s/.*/&\/config\n&\/HEAD/" >git_filelist

$SCRIPT_DIR/makeusr "%{_android_platform}" "$PRODUCT_DIR"

mkdir -p $RPM_BUILD_ROOT/aroot/toolchain/bin
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
sed -f $SCRIPT_DIR/../data/no_product_copy.sed <$RPM_BUILD_DIR/build/core/Makefile >build/core/Makefile

# if we are not running on a stripped sysroot, we need to 
# add a null.mk to dalvik.  No effect on the full build but it
# would be better if the stripped makerules added this dynamically
if [ ! -e dalvik/null.mk ]; then
    touch dalvik/null.mk
fi

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
# we want a consistent name for the toolchain.
cd bin
for i in addr2line ar as c++ c++filt cpp elfedit g++ gcc gcc-4.6.x-google gcov gdb gdbtui gprof ld ld.bfd ld.gold nm objcopy objdump ranlib readelf run size strings strip; do
    [ -e ../../${TOOLPREFIX}$i ] && ln -s ../../${TOOLPREFIX}$i arm-bionic-eabi-$i;
    [ -e ../../${TOOLPREFIX}$i ] && ln -s ../../${TOOLPREFIX}$i arm-linux-$i;
done

cd ..
GCC_SPEC_DIR=`bin/arm-linux-gcc -print-search-dirs | fgrep install: | sed -e "s/install: //"`
cp $SCRIPT_DIR/../data/gcc_sysroot.specs $GCC_SPEC_DIR/specs
ln -s $GCC_SPEC_DIR/specs .
mkdir -p libgcc-arm
cd libgcc-arm
LIB_GCC=
if test "%{_android_arch}" == "arm" ; then
    case  "%{_android_platform}" in
	"2.3.4" | "2.3.5" | "2.3.6" | "2.3.7") 
            LIB_GCC=`ls ../../${TC_DIR}/lib/gcc/$TOOL_DIRNAME/*/android/libgcc.a`
            ;;
	"4.0.4" | "4.1.1" | "4.1.2") 
            LIB_GCC=`ls ../../${TC_DIR}/lib/gcc/$TOOL_DIRNAME/*/armv7-a/libgcc.a`
            ;;
        *)
            echo "prebuilt.spec: ERROR: where is your libgcc.a?"
            ;;
    esac
else
    # needed for x86 target
    LIB_GCC=`ls ../../${TC_DIR}/lib/gcc/$TOOL_DIRNAME/*/libgcc.a`
fi
echo LIBGCC $LIB_GCC
if test "$LIB_GCC" != "" ; then
    ln -s $LIB_GCC .
fi

%package toolchain
BuildArch: noarch
Summary: gcc cross compiler
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
Summary: /usr/include and /usr/lib
AutoReqProv: 0
%description %{_android_product}_devel
The 'devel' package contains the headers, libraries and build scripts
needed to compile other source packages.  (but not the compiler)
%files %{_android_product}_devel -f devel_filelist
/aroot/usr/*
/aroot/bionic/lib*/include
/aroot/bionic/libc/arch-*/include
/aroot/bionic/libc/kernel/common
/aroot/bionic/libc/kernel/arch-*
/aroot/Makefile
/aroot/dalvik/null.mk
/aroot/system/core/include
/aroot/external/stlport/stlport
/aroot/out/host/linux-x86/bin
/aroot/git_files.tgz
