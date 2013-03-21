set -x

if echo $- | grep -q i
then
    echo 'Do not source the build script!'
    return
fi

DISTRIB_ID=`lsb_release -i | sed 's/^[^:]*:[[:blank:]]*//'`
DISTRIB_RELEASE=`lsb_release -r | sed 's/^[^:]*:[[:blank:]]*//'`

SELF=`which -- $0`

cd $(readlink -f $(dirname $(which -- $SELF)))

generic_error()
{
        LINE=`caller | awk '{print $1}'`
        FILE=`caller | awk '{print $2}'`
        echo -e "\033[1mUnhandled error executing:\033[0m ${BASH_COMMAND}"
        echo -e "(Error at line ${LINE} in ${FILE})"
        exit 1
}

check_mkimage()
{
    local pkg
    if ! which mkimage &>/dev/null
    then
        echo "Missing tool mkimage!"
        case ${DISTRIB_ID} in
            Ubuntu)
                case ${DISTRIB_RELEASE} in
                    10.*) pkg=uboot-mkimage;;
                    11.*) pkg=u-boot-tools;;
                    12.*) pkg=u-boot-tools;;
                    *) pkg=uboot-mkimage/u-boot-tools;;
                esac
                echo "Please install package ${pkg} for mkimage"
                echo "    sudo apt-get install ${pkg}"
                ;;
            Gentoo)
                echo "Please install package u-boot-tools for mkimage"
                echo "    sudo emerge -av u-boot-tools"
                ;;
            *)
                echo "Please install whatever package your distribution has"
                echo "for the utility make image.  It may be called u-boot-tools."
                ;;
        esac
        exit 1
    fi
}

mktemp_env_cleanup()
{
    # Ensure any mount points are umounted before erasing files!
    umount_all && [ ! "${#TMP_FILES[*]}" == "0" ] && rm -rf ${TMP_FILES[*]}
}

mktemp_env()
{
    # Ensure the cleanup function is trapped.
    trap mktemp_env_cleanup EXIT
    local MKTEMP_OUT
    MKTEMP_OUT=`mktemp ${*:2}`
    TMP_FILES[${#TMP_FILES[*]}]="${MKTEMP_OUT}"
    eval $1=${MKTEMP_OUT}
}


if [ ! -e "build-tools/build_local.sh" ]
then
    echo "Please setup a build-tools/build_local.sh file for build customizations."
    exit 0
fi

BUILD_TARGETS=

copy_function() {
    declare -F $1 > /dev/null || return 1
    eval "$(echo "${2}()"; declare -f ${1} | tail -n +2)"
}

bytes_to_human_readable()
{
    local spaces="     "
    local prefix=" kMGTPE"
    local val=$1
    local pos=0
    local precision=10
    local divider=1024
    local compare
    local digits
    local end

    ((val = val * precision))
    ((compare = divider * precision))
    while [ ${val} -gt ${compare} ]
    do
        ((pos++))
        ((val = val / divider))
    done

    digits=${#val}
    ((end=digits-${#precision}+1))
    echo "${spaces:digits}${val::end}.${val:end}${prefix:pos:1}B"
}

is_valid_removable_device()
{
    local capability

    capability=0x0`cat /sys/block/$1/capability 2>/dev/null`

    if (( (capability & 0x41) == 0x41 )) &&
       [ "`cat /sys/class/block/$1/size`" != "0" ]
    then
        return 0
    fi
    return 1
}

find_removable_devices()
{
    local i
    local dev
    local capability
    local cnt=0

    for i in /sys/block/*
    do
        dev=`echo $i | awk -F / '{print $4}'`
        if is_valid_removable_device ${dev}
        then
            eval $1[$cnt]=${dev}
            ((cnt++)) || true
        fi
    done
}

choose_removable_device()
{
    local DEV_LIST[0]
    local i

    if is_valid_removable_device ${DEV}
    then
        return 0
    fi

    if [ ! "${DEV}" == "" ]
    then
        echo "Overriding invalid device selection ${DEV}"
    fi

    while true
    do
        find_removable_devices DEV_LIST

        if [ "${#DEV_LIST[*]}" == "0" ]
        then
            echo "Error: No possible SD devices found on system."
            return 1
        fi

        set -o emacs
        bind 'set show-all-if-ambiguous on'
        bind 'set completion-ignore-case on'
        COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
        bind 'TAB:dynamic-complete-history'
        for i in ${DEV_LIST[*]} ; do
            history -s $i
        done

        echo Devices available:
        for i in ${DEV_LIST[*]}
        do
            local size
            size=$((`cat /sys/block/${i}/size`*512))
            size=`bytes_to_human_readable ${size}` || true

            echo "  ${i} is ${size} - `cat /sys/block/${i}/device/model`"
        done

        read -ep "Enter device: " DEV
        if is_valid_removable_device ${DEV}
        then
            if ! sudo -v -p "Enter %p's password, for SD manipulation permissions: "
            then
                echo "Cannot continue; you did not authenticate with sudo."
                return 1
            fi
            sleep 1
            echo
            return 0
        fi
        echo "Enter a valid device."
        echo "You can choose one of ${DEV_LIST[*]}"
    done
}

find_device_partition()
{
    local find_part
    local I
    for I in /sys/block/$2/*/partition
    do
        find_part=`echo $I | awk -F / '{print $5}'`
        if echo ${find_part} | grep -q "[^0123456789]$3\$"
        then
            eval $1=${find_part}
            return 0
        fi
    done
    echo "Unable to find partition #$3 for $2"
    return 1
}

unmount_device()
{
    local I
    local MNT_POINTS

    choose_removable_device

    MNT_POINTS=`cat /proc/mounts | grep $DEV | awk '{print $2}' | sed 's/\\\\0/\\\\00/g'`
    for I in ${MNT_POINTS}
    do
        echo -e "Unmounting ${I}"
        sudo umount "`echo -e ${I}`" || return 1
    done
}

mount_bootloader()
{
    local part

    if [ "${MNT_BOOTLOADER}" == "" ]
    then
        choose_removable_device
        mktemp_env MNT_BOOTLOADER -d
        find_device_partition part ${DEV} 1
        echo "Mounting bootloader partition"
        sudo mount /dev/${part} ${MNT_BOOTLOADER} -o uid=`id -u`
    fi
}

mount_root()
{
    local part

    if [ "${MNT_ROOT}" == "" ]
    then
        choose_removable_device
        mktemp_env MNT_ROOT -d
        find_device_partition part ${DEV} 2
        echo "Mounting root partition"
        sudo mount /dev/${part} ${MNT_ROOT}
    fi
}

build_info()
{
    echo -en "\033[1m$* - \033[0m" 1>&3
}

umount_all()
{
    if [ ! "${MNT_BOOTLOADER}" == "" ] ||
       [ ! "${MNT_ROOT}" == "" ]
    then
        echo "Flushing data to SD card"
        sync
    fi

    cd ${ROOT}

    if [ ! "${MNT_BOOTLOADER}" == "" ]
    then
        echo "Unmounting bootloader partition"
        sudo umount ${MNT_BOOTLOADER}
        rmdir ${MNT_BOOTLOADER}
        MNT_BOOTLOADER=
    fi

    if [ ! "${MNT_ROOT}" == "" ]
    then
        echo "Unmounting root partition"
        sudo umount ${MNT_ROOT}
        rmdir ${MNT_ROOT}
        MNT_ROOT=
    fi
}

check_component()
{
    if [ ! -e "${1}" ]
    then
        echo "Missing \"${1}\"! Cannot continue."
        exit 1
    fi
    if [ "${CHECKING_COMPONENTS}" == "1" ]
    then
        if [ ! "${1:0:1}" == "/" ]
        then
            echo -en "${ROOT}" 1>&4
        fi
        echo "${1}" 1>&4
    fi
}

finished_checking_components()
{
    if [ "${CHECKING_COMPONENTS}" == "1" ]
    then
        exit 255
    fi
}

copy_reflash_nand_sd()
{
    echo "Copying reflash nand SD components."
    cd ${ROOT}
    mkdir -p $1/update

    # Update x-loader in place if possible.
    cat ${PATH_TO_XLOADER}/x-load.bin.ift                                 > $1/MLO
    cp ${LINK} ${PATH_TO_UBOOT}/u-boot.bin                                  $1/u-boot.bin
    cp ${LINK} ${PATH_TO_UBOOT}/u-boot.bin.ift                              $1/
    cp ${LINK} ${ANDROID_PRODUCT_OUT}/boot.img                              $1/
    cp ${LINK} ${ANDROID_PRODUCT_OUT}/system.img                            $1/
    cp ${LINK} ${ANDROID_PRODUCT_OUT}/userdata.img                          $1/
    mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n \
            "Logic PD Android SD Boot" -d \
            device/logicpd/${TARGET_PRODUCT}/reflash_nand.cmd \
        ${1}/boot.scr > /dev/null 2>&1
}

copy_update_cache()
{
    check_mkimage

    cd ${ROOT}
    mkdir -p $1

    cp ${LINK} ${PATH_TO_UBOOT}/u-boot.bin.ift                              $1
    cp ${LINK} ${PATH_TO_XLOADER}/x-load.bin.ift                            $1/MLO
    cp ${LINK} ${ANDROID_PRODUCT_OUT}/boot.img                              $1/uMulti-Image
    cp ${LINK} ${ANDROID_PRODUCT_OUT}/system.img                            $1
    cp ${LINK} ${ANDROID_PRODUCT_OUT}/userdata.img                          $1
}

deploy_build_out()
{
    if [ "$CLEAN" == "1" ]
    then
        echo "Removing build-out."
        rm -Rf build-out
        return 0
    fi

    cd ${ROOT}

    # Check necessary files.
    check_component ${PATH_TO_XLOADER}/x-load.bin.ift
    check_component ${PATH_TO_UBOOT}/u-boot.bin
    check_component ${PATH_TO_UBOOT}/u-boot.bin.ift
    check_component ${PATH_TO_UBOOT}/u-boot-no-environ_bin
    check_component ${ANDROID_PRODUCT_OUT}/boot.img
    check_component ${ANDROID_PRODUCT_OUT}/system.img
    check_component ${ANDROID_PRODUCT_OUT}/userdata.img
    check_component ${ROOT}/device/logicpd/${TARGET_PRODUCT}/android.bmp
    check_component ${ROOT}/device/logicpd/${TARGET_PRODUCT}/android2.bmp
    check_component ${ROOT}/device/logicpd/${TARGET_PRODUCT}/done.bmp
    check_component device/logicpd/${TARGET_PRODUCT}/reflash_nand.cmd
    finished_checking_components
    
    mkdir -p build-out/reflash_nand_sd/update
    mkdir -p build-out/update_cache

    rm -Rf build-out
    mkdir -p build-out
    
    # Copy over x-loader binaries
    cp -l ${PATH_TO_XLOADER}/x-load.bin.ift build-out/MLO

    # Copy over u-boot binaries
    cp -l ${PATH_TO_UBOOT}/u-boot.bin     build-out/
    cp -l ${PATH_TO_UBOOT}/u-boot.bin.ift build-out/

    # Copy over to reflash_nand_sd
    LINK=-l copy_reflash_nand_sd build-out/reflash_nand_sd/

    # Copy over to update_cache
    #LINK=-l copy_update_cache build-out/update_cache/
}

deploy_sd_unmount_all_and_check()
{
    if umount_all
    then
        if cat /proc/mounts | grep -q ${DEV}
        then
            echo -e "Image deployed, but \033[1mthe SD card is mounted by the system.\033[0m"
            echo "Please safely remove your SD card."
        else
            echo "Image deployed. SD card can be removed."
        fi
    else
        echo "Image deployment failed!"
    fi
}

deploy_sd()
{
    check_mkimage

    local TMP_INIT

    if [ "$CLEAN" == "1" ]
    then
        echo "Nothing to be done for clean when deploying to SD"
        return 0
    fi

    cd ${ROOT}

    # Check necessary files.
    check_component ${PATH_TO_XLOADER}/x-load.bin.ift
    check_component ${PATH_TO_UBOOT}/u-boot.bin
    check_component ${PATH_TO_KERNEL}/arch/arm/boot/uImage
    check_component ${ANDROID_PRODUCT_OUT}/root.tar.bz2
    check_component ${ANDROID_PRODUCT_OUT}/system.tar.bz2
    check_component ${ANDROID_PRODUCT_OUT}/userdata.tar.bz2
    check_component ${ROOT}/device/logicpd/${TARGET_PRODUCT}/boot_sd.cmd
    finished_checking_components

    mount_bootloader
    mount_root

    # Using CAT to update the MLO file inplace;
    # this way it doesn't break the ability to boot.
    cat ${PATH_TO_XLOADER}/x-load.bin.ift > ${MNT_BOOTLOADER}/MLO
    cp ${PATH_TO_UBOOT}/u-boot.bin ${MNT_BOOTLOADER}
    cp ${PATH_TO_KERNEL}/arch/arm/boot/uImage ${MNT_BOOTLOADER}
    mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n \
            "Logic PD Android SD Boot" -d \
            device/logicpd/${TARGET_PRODUCT}/boot_sd.cmd \
        ${MNT_BOOTLOADER}/boot.scr > /dev/null 2>&1

    # Install root files from the various tarballs
    cd ${MNT_ROOT}
    sudo rm -Rf ${MNT_ROOT}/*

    echo Extracting root tarball
    sudo tar --numeric-owner -xjf ${ANDROID_PRODUCT_OUT}/root.tar.bz2

    echo Extracting system tarball
    sudo tar --numeric-owner -xjf ${ANDROID_PRODUCT_OUT}/system.tar.bz2

    echo Extracting userdata tarball
    sudo tar --numeric-owner -xjf ${ANDROID_PRODUCT_OUT}/userdata.tar.bz2

    echo Filtering init.rc for mtd mount commands
    mktemp_env TMP_INIT
    sudo cat init.rc | egrep -v 'mount.*(mtd@|rootfs.*remount)' > ${TMP_INIT}
    sudo cp ${TMP_INIT} init.rc
    rm ${TMP_INIT}

    deploy_sd_unmount_all_and_check
}

deploy_nand()
{
    if [ "$CLEAN" == "1" ]
    then
        echo "Nothing to be done for clean when deploying to SD NAND"
        return 0
    fi

    cd ${ROOT}

    # Check necessary files.
    check_component ${PATH_TO_XLOADER}/x-load.bin.ift
    check_component ${PATH_TO_UBOOT}/u-boot.bin
    check_component ${PATH_TO_UBOOT}/u-boot-no-environ_bin
    check_component ${ANDROID_PRODUCT_OUT}/boot.img
    check_component ${ANDROID_PRODUCT_OUT}/system.img
    check_component ${ANDROID_PRODUCT_OUT}/userdata.img
    finished_checking_components

    mount_bootloader

    # Install root files from the various tarballs
    rm -Rf ${MNT_BOOTLOADER}/update
    mkdir -p ${MNT_BOOTLOADER}/update
    copy_reflash_nand_sd ${MNT_BOOTLOADER}/

    deploy_sd_unmount_all_and_check
}

update_boot_img()
{
    check_mkimage

    if [ -e "${PATH_TO_KERNEL}/arch/arm/boot/zImage" ] &&
       [ -e "${ANDROID_PRODUCT_OUT}/ramdisk.img" ]
    then
        # Create boot.img
        mkimage -A arm -O linux -T multi -C none -a 0x82000000 -e 0x82000000 -n 'Logic PD' \
            -d ${PATH_TO_KERNEL}/arch/arm/boot/zImage:${ANDROID_PRODUCT_OUT}/ramdisk.img \
            ${ANDROID_PRODUCT_OUT}/boot.img
    fi
}

build_android()
{
    cd ${ROOT}

    if [ "$CLEAN" == "0" ]
    then
        make -j${JOBS}
        update_boot_img
    else
        make -j${JOBS} clean
    fi
}

uboot_check_config()
{
    local BOARD
    local VENDOR
    local SOC

    BOARD=`cat include/config.mk 2>/dev/null | awk '/BOARD/ {print $3}'`
    VENDOR=`cat include/config.mk 2>/dev/null | awk '/VENDOR/ {print $3}'`
    SOC=`cat include/config.mk 2>/dev/null | awk '/SOC/ {print $3}'`

    # If the configuration isn't set, set it.
    if [ ! "$UBOOT_BOARD" == "$BOARD" ] ||
       [ ! "$UBOOT_VENDOR" == "$VENDOR" ] ||
       [ ! "$UBOOT_SOC" == "$SOC" ]
    then
        make ${TARGET_UBOOT}_config
    fi
}

build_uboot()
{
    cd ${PATH_TO_UBOOT}

    PATH=${BOOTLOADER_PATH}    

    if [ "$CLEAN" == "0" ]
    then
        uboot_check_config
        make -j${JOBS}
    else
        make -j${JOBS} distclean
        rm -f include/config.mk
    fi
}

build_uboot_no_env()
{
    local CLEAN

    if [ "${CLEAN}" == "1" ]
    then
        rm -f build-out/u-boot-no-environ_bin
    else
        if [ ! -e ${PATH_TO_UBOOT}/u-boot-no-environ_bin ]
        then
            CLEAN=1 build_uboot
            CLEAN=0 CMDLINE_FLAGS=-DFORCED_ENVIRONMENT build_uboot
            cp ${PATH_TO_UBOOT}/u-boot.bin ${PATH_TO_UBOOT}/u-boot-no-environ_bin
            CLEAN=1 build_uboot
        fi
    fi
}

build_xloader()
{
    local PATH
    local TARGET

    cd ${PATH_TO_XLOADER}
    PATH=${BOOTLOADER_PATH}
    TARGET=`cat include/config.mk 2>/dev/null | awk '/BOARD/ {print $3}'`

    if [ "$CLEAN" == "0" ]
    then
        # If the configuration isn't set, set it.
        if [ ! "$TARGET_XLOADER" == "$TARGET" ]
        then
            make ${TARGET_XLOADER}_config
        fi

        # X-Loader sometimes fails with multiple build jobs.
        make
    else
        make -j${JOBS} distclean
        rm -f include/config.mk
    fi
}

build_kernel()
{
    local PATH

    cd ${PATH_TO_KERNEL}
    PATH=${KERNEL_PATH}

    if [ "$CLEAN" == "0" ]
    then
        if [ ! -e ".config" ] 
        then
            echo "Using default kernel configuration."
            make ${TARGET_KERNEL} -j${JOBS} && make uImage modules -j${JOBS}
        else
            echo "Using existing kernel configuration."
            echo "To reset to default configuration, do:"
            echo "  cd kernel"
            echo "  ARCH=arm make ${TARGET_KERNEL}"
            echo ""
            make uImage modules -j${JOBS}
        fi
        make CROSS_COMPILE=arm-none-linux-gnueabi- modules_install INSTALL_MOD_PATH=${ANDROID_PRODUCT_OUT}/modules
        echo ""
        echo "Installing modules included in kernel to rootfs..."
        echo ""
        mkdir -p ${ANDROID_PRODUCT_OUT}/root
        for f in $(find ${ANDROID_PRODUCT_OUT}/modules -type f -name '*.ko'); do cp "$f" ${ANDROID_PRODUCT_OUT}/root/ ; done
        mkdir -p ${ANDROID_PRODUCT_OUT}/system/etc
        cp -a ${ANDROID_PRODUCT_OUT}/modules/lib/firmware ${ANDROID_PRODUCT_OUT}/system/etc
        update_boot_img
    else
        make clean -j${JOBS}
    fi
}

build_sub_module()
{
    local CMD
    local PATH

    cd ${ROOT}
    CMD="make -C $* ANDROID_ROOT_DIR=${ROOT} -j${JOBS}"
    PATH=${KERNEL_PATH}

    if [ "$CLEAN" == "0" ]
    then
        echo ${CMD}
        ${CMD}
        ${CMD} install
    else
        ${CMD} clean
    fi
}

build_sgx_modules()
{
    local TARGET_ROOT

    if [ "$CLEAN" == "0" ] && 
           [ ! -e "${ANDROID_PRODUCT_OUT}/obj/lib/crtbegin_dynamic.o" ]
    then
        build_info needs Android built to finish
        return 0
    fi

    # The make files for sgx are looking for the variable TARGET_ROOT
    # to help determine the version of android we're running.
    TARGET_ROOT=${ROOT}

    # Make sure the output folder exists (the compile requires this!)
    [ "$CLEAN" == "0" ] && mkdir -p ${ANDROID_PRODUCT_OUT}

    if [ "$SKIP_SGX" == "1" ]
    then
        build_info "SKIP_SGX is set - skipping SGX build"
        return 0
    fi

    build_sub_module hardware/ti/sgx OMAPES=5.x PLATFORM_VERSION=${PLATFORM_VERSION}
}

build_wl12xx_modules()
{
        build_sub_module hardware/ti/wlan/WL1271_compat/drivers
}

build_images()
{
    # Remove old, stale image files.
    rm -f `find out -iname system.img`
    rm -f `find out -iname system.tar.bz2`
    rm -f `find out -iname userdata.img`
    rm -f `find out -iname userdata.tar.bz2`
    rm -f `find out -iname ramdisk.img`
    rm -f `find out -iname boot.img`

    if [ "${CLEAN}" == "1" ]
    then
        # Force removal of output folders
        rm -Rf ${ANDROID_PRODUCT_OUT}/root
        rm -Rf ${ANDROID_PRODUCT_OUT}/data
        rm -Rf ${ANDROID_PRODUCT_OUT}/system
        rm -Rf ${ANDROID_PRODUCT_OUT}/modules
    else
        # Do normal Android image creation (including tarball images)
        make systemimage userdataimage ramdisk systemtarball userdatatarball

        # Create root.tar.bz2
        cd ${ANDROID_PRODUCT_OUT}
        ../../../../build/tools/mktarball.sh ../../../host/linux-x86/bin/fs_get_stats root . root.tar root.tar.bz2
        cd ${ROOT}

        # Create boot.img
        update_boot_img
    fi
}

build_fastboot()
{
    if [ "$1" == "all" ]
    then
        fastboot flash boot
        fastboot flash system
        fastboot flash userdata
        fastboot reboot
    else
        fastboot flash $1
    fi
}

build_error()
{
    exit 1
}

build()
{
    local ERR=0
    local TMP
    local TIME
    local NAME
    local VERB
    local VERB_ACTIVE

    mktemp_env TMP
    mktemp_env TIME

    if [ "${CLEAN}" == "1" ]
    then
        VERB="clean"
        VERB_ACTIVE="cleaning"
    else
        VERB="build"
        VERB_ACTIVE="building"
    fi

    NAME=`printf "%-15s" ${1}`

    echo -en "${VERB_ACTIVE^*} ${NAME}"

    if [ "${VERBOSE}" == "1" ]
    then
        echo ""
        set +E
        trap - ERR
        time ((
            trap build_error ERR
            set -E
            build_$1 2>&1
              ) | tee ${TMP}
              [ "${PIPESTATUS[0]}" == "0" ] || false
             ) 2>${TIME} 3>&1
        [ ! "$?" == "0" ] && ERR=1
        echo -en "Finished ${VERB_ACTIVE} ${NAME} - "
        trap generic_error ERR
        set -E
    else
        echo -en " - "
        set +E
        trap - ERR
        time (
            trap build_error ERR
            set -E
            build_$1 &> ${TMP}
             ) 2> ${TIME} 3>&1
        [ ! "$?" == "0" ] && ERR=1
        trap generic_error ERR
        set -E
    fi

    if [ "$ERR" != "0" ]
    then
        echo -en "failure ${VERB_ACTIVE}.\nSee ${ROOT}/error.log.\n"
        mv ${TMP} ${ROOT}/error.log
        if [ "${EXIT_ON_ERROR}" == "1" ]
        then
            rm ${TIME}
            exit 1
        fi
    else
        echo -en "took "
        echo -en `cat ${TIME}`
        echo -e " to ${VERB}."
        rm ${TMP}
    fi
    rm ${TIME}

    return ${ERR}
}

deploy_fastboot()
{
    if [ "$CLEAN" == "1" ]
    then
        echo "Nothing to do for clean while deploying to fastboot."
        return 0
    fi

    finished_checking_components

    while true
    do
        echo "Waiting for device"
        while [ "`fastboot devices | wc -l`" == "0" ]
        do
            sleep 1
        done

        while ! EXIT_ON_ERROR=0 build kernel
        do
            less ${ROOT}/error.log
        done
        fastboot boot ${ANDROID_PRODUCT_OUT}/boot.img
        sleep 10
    done
}


deploy()
{
    echo "Deploying to $1"
    deploy_$1 ${*:2}
}


kernel_config()
{
    cd ${PATH_TO_KERNEL}
    make menuconfig
}

# Setup some environment variables.
TIMEFORMAT='%R seconds'
ROOT=${PWD}
JOBS=8
CLEAN=0
VERBOSE=0
DEV=
EXIT_ON_ERROR=1

PATH_TO_KERNEL=${ROOT}/kernel
PATH_TO_UBOOT=${ROOT}/u-boot
PATH_TO_XLOADER=${ROOT}/x-loader

export ARCH=arm
export CROSS_COMPILE=arm-eabi-

BOOTLOADER_PATH=${ROOT}/prebuilt/linux-x86/toolchain/arm-eabi-4.4.0/bin:${PATH}
KERNEL_PATH=${ROOT}/prebuilt/linux-x86/toolchain/arm-eabi-4.4.3/bin:${PATH}
ORIG_PATH=${PATH}

export PATH=${BOOTLOADER_PATH}

source build-tools/build_local.sh

BOOTLOADER_PATH=${PATH_TO_UBOOT}/tools:${BOOTLOADER_PATH}
KERNEL_PATH=${PATH_TO_UBOOT}/tools:${KERNEL_PATH}
ORIG_PATH=${PATH_TO_UBOOT}/tools:${ORIG_PATH}
PATH=${PATH_TO_UBOOT}/tools:${PATH}

echo "Updating Android build environment cache"
(
    mktemp_env TMP
    mktemp_env UPT
    REGEX_CLEAN_ROOT=`echo -en "${ROOT}" | sed -re 's/(]|[[\\\/.+*?{\(\)\|\^])/\\\\\1/g'`

    export > ${TMP}
    . build/envsetup.sh
    echo lunch ${TARGET_ANDROID}
    lunch ${TARGET_ANDROID}
    export `cat ${ROOT}/build/core/version_defaults.mk | grep PLATFORM_VERSION[^_].*= | tr -d ': '`
    declare -x | sed -re 's|"('${REGEX_CLEAN_ROOT}')|"${ROOT}|g' > ${UPT}

    diff  --left-column ${TMP} ${UPT} |
        grep '^> ' |
        sed 's/^> //' |
        grep -v '^declare -x PATH=' |
        sed 's/^declare -x /export /' |
        sed -re 's|:('${REGEX_CLEAN_ROOT}')|:${ROOT}|g' > .cached_android_env
    rm -f ${UPT} ${TMP}
) > /dev/null

source ${ROOT}/.cached_android_env
export PATH=${PATH}${ANDROID_BUILD_PATHS}

if [ "${TARGET_UBOOT}" == "" ] ||
   [ "${TARGET_XLOADER}" == "" ] ||
   [ "${TARGET_ANDROID}" == "" ] ||
   [ "${TARGET_KERNEL}" == "" ] ||
   [ "${UBOOT_BOARD}" == "" ] ||
   [ "${UBOOT_VENDOR}" == "" ] ||
   [ "${UBOOT_SOC}" == "" ]
then
    echo "Please setup build_local.sh properly."
    exit 0
fi
JOBS=30

trap generic_error ERR
set -E

build xloader
build uboot_no_env
build kernel
build android
build sgx_modules
build uboot_fastboot
build uboot
build images
deploy build_out

