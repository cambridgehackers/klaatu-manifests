#!/bin/bash
#RPM_DIR=~/rpm
#RPM_ANDROID_VERSION=4.0.4_r1.2
#RPM_PRODUCT=maguro
RPM_DIR=$1
RPM_ANDROID_VERSION=$2
RPM_PRODUCT=$3
RPM_VERSION=-1-1
rpm2cpio ${RPM_DIR}/android_${RPM_ANDROID_VERSION}-toolchain${RPM_VERSION}.noarch.rpm | cpio -idm
rpm2cpio ${RPM_DIR}/android_${RPM_ANDROID_VERSION}-${RPM_PRODUCT}_devel${RPM_VERSION}.noarch.rpm | cpio -idm
sed -i.001 --follow-symlinks -e "s/\/aroot/${PWD//\//\\/}&/" aroot/toolchain/specs
