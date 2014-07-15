#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"

. $script_dir/repo_mirror.sh
. $script_dir/multi_manifests.sh
. $script_dir/patches.sh

#repo_init -u git://codeaurora.org/platform/manifest.git -b release -m M8960AAAAANLYA2304.xml
repo_init -u git://codeaurora.org/platform/manifest.git -b release -m M8960AAAAANLYA2016183.xml

set_ui_defaults qt busybox

manifests="$(get_manifests)"

mkdir -p .repo/local_manifests

if [ -n "$manifests" ]; then cp $manifests .repo/local_manifests/; fi

export KLAATU_DEFAULT_UI=$(get_default_ui)

repo_sync

patch_build

. build/envsetup.sh
choosecombo 2 msm8960 eng
make -j${NUM_CPUS}
