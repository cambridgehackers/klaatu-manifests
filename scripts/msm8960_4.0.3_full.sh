#
set -e
set -x
#build for 4.0.3

repo init -u git://codeaurora.org/platform/manifest -b ics_chocolate -m M8960AAAAANLYA1031A.xml 
ln -sf ~/bionicsf-manifests/manifests/cambridge-vendor-4.0.3.xml .repo/local_manifest.xml
repo sync -n -j 4 && repo sync -l -j 20
ln -sf ../../vendor_extra/qcom/proprietary vendor/qcom/
echo "source build/envsetup.sh; choosecombo 2 msm8960 eng"
