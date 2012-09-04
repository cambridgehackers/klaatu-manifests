#
set -e
set -x
#build for 4.1.1
ANDROID_GENERIC_HOST=${ANDROID_GENERIC_HOST:-https://android.googlesource.com/}
ANDROID_GENERIC_HOST_CODEAURORA=${ANDROID_GENERIC_HOST_CODEAURORA:-git://codeaurora.org}
ANDROID_GENERIC_HOST_OMAPZOOM=${ANDROID_GENERIC_HOST_OMAPZOOM:-git://git.omapzoom.org}

repo init -u $ANDROID_GENERIC_HOST_CODEAURORA/platform/manifest -b release -m M8960AAAAANLYA2004.xml 
ln -s ~/bionicsf-manifests/manifests/cambridge-vendor-4.1.1.xml .repo/local_manifest.xml
sed -i.001  -e "s/git:\/\/codeaurora.org/../" -e "s/git:\/\/git.omapzoom.org/../" .repo/manifest.xml 
repo sync -n -j 4 && repo sync -l -j 20
ln -s ../../vendor_extra/qcom/proprietary vendor/qcom/
source build/envsetup.sh; choosecombo 2 msm8960 eng
