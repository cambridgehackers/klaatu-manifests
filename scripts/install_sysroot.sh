#
#rpm2cpio ../android_4.0.4_r1.2-toolchain-1-1.noarch.rpm | cpio -idm
#rpm2cpio ../android_4.0.4_r1.2-maguro_devel-1-1.noarch.rpm | cpio -idm
RPM_DIR=~/android_
RPM_ANDROID_VERSION=4.0.4_r1.2
RPM_VERSION=-1-1.noarch.rpm
RPM_PRODUCT=maguro
rpm2cpio ${RPM_DIR}${RPM_ANDROID_VERSION}-toolchain${RPM_VERSION} | cpio -idm
rpm2cpio ${RPM_DIR}${RPM_ANDROID_VERSION}-${RPM_PRODUCT}_devel${RPM_VERSION} | cpio -idm
sed -i.001 --follow-symlinks -e "s/\/aroot/${PWD//\//\\/}&/" aroot/toolchain/specs
