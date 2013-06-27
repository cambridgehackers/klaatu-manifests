#!/bin/bash -xel

script_dir="$( cd "$( dirname "$0" )" && pwd )"
. $script_dir/repo_mirror.sh

klaatu_manifests=$script_dir/../manifests

repo_init -u git://github.com/cubieboard/manifests -b cb -m openbox.xml

#$script_dir/strip-projects.sh .repo/manifest.xml

mkdir -p .repo/local_manifests
cp ../klaatu-manifests/manifests/qt_2012-05-30-generic.xml .repo/local_manifests/
cat <<EOF >.repo/local_manifests/local_manifest.xml
<manifest>
  <remote name="cambridge" fetch="git://gitorious.org/cambridge/" />
  <project path="external/klaatu-qt-demos" name="klaatu-qt-demos" remote="cambridge" revision="master"/>
</manifest>
EOF

repo_sync

#$script_dir/fixup_common.sh

. build/envsetup.sh

lunch 4

make update-api

make -j${NUM_CPUS}
make

tools/pack-cm.sh

cp -a tools/pack/sun4i_crane_cubieboard.img out/target/product/cubieboard/
