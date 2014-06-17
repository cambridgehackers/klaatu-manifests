#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh
. $script_dir/patches.sh

repo init -u https://android.googlesource.com/platform/manifest -b android-4.4.3_r1.1 "$@"

mkdir -p .repo/local_manifests
cat <<EOF >.repo/local_manifests/local_manifest.xml
<manifest>
  <remote name="github" fetch="https://github.com/kivatu" />
  <project path="vendor" name="vendor" remote="github" revision="4.4.3_hammerhead_ktu84m"/>
  <project path="kernel" name="kernel/msm" revision="android-msm-hammerhead-3.4-kitkat-mr2" />
</manifest>
EOF

repo sync "$@"

patch_build

. build/envsetup.sh

lunch aosp_hammerhead-userdebug

make -j${NUM_CPUS}
