#
set -e
set -x
#build for 4.1.1

repo init -u git://codeaurora.org/platform/manifest -b release -m M8960AAAAANLYA2004.xml 
ln -sf ~/bionicsf-manifests/manifests/cambridge-vendor-4.1.1.xml .repo/local_manifest.xml
repo sync -n -j 4 && repo sync -l -j 20
ln -sf ../../vendor_extra/qcom/proprietary vendor/qcom/
echo "source build/envsetup.sh; choosecombo 2 msm8960 eng"
