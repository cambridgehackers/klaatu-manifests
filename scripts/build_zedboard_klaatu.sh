#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"

. $script_dir/repo_mirror.sh
. $script_dir/multi_manifests.sh

repo init -u https://android.googlesource.com/platform/manifest -b android-4.1.2_r2

mkdir -p .repo/local_manifests
cat <<EOF >.repo/local_manifests/local_manifest.xml
<manifest>
  <!-- Add zedboard -->
  <remote name="cambridgehackers" fetch="https://github.com/cambridgehackers"/>

  <project path="device/xilinx/gralloc" name="device_xilinx_gralloc" 
           remote="cambridgehackers" revision="master" />
  <project path="device/xilinx/hwcomposer" name="device_xilinx_hwcomposer"
           remote="cambridgehackers" revision="master" />
  <project path="device/xilinx/zedboard" name="device_xilinx_zedboard"
           remote="cambridgehackers" revision="master" />
  <project path="device/xilinx/zedmini" name="device_xilinx_zedmini"
           remote="cambridgehackers" revision="master" />
  <project path="device/xilinx/kernel" name="device_xilinx_kernel" 
           remote="cambridgehackers" revision="digilent-android-3.3" />
</manifest>
EOF

repo sync
source build/envsetup.sh; lunch zedboard-userdebug
make -j${NUM_CPUS}
#make -j${NUM_CPUS} userdataimage-nodeps systemimage-nodeps
