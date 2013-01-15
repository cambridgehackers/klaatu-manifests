#!/bin/bash -e

if [ -z "$1" ] || [ -z "$WORKSPACE" ]; then
        echo "usage $0 BUILD_SCRIPT BUILD_DIR OUT_DIR"
        exit 1
fi

script="$(dirname $0)/$1"
shift

build_dir="/ramdisk/jenkins_builds/${JOB_NAME}_${BUILD_ID}"

echo "Build start at $(date --rfc-3339=seconds)"

rm -f $WORKSPACE/*
if ( "$script" $build_dir ); then
	out_dir=`find "$build_dir/out/" -name userdata.img`
	if [ -n "$out_dir" ]; then
		out_dir=`dirname "$out_dir"`
		cp -a "$out_dir"/*.*  $WORKSPACE
		tar -zcvf $WORKSPACE/system.tar.gz -C "$out_dir" system
		tar -zcvf $WORKSPACE/root.tar.gz -C "$out_dir" root
	else
		echo "error userdata.img not found"
		mkdir -p "/home/builds/jenkins_builds/$JOB_NAME/$BUILD_ID"/out
		rsync -a --exclude obj $build_dir/out/ "/home/builds/jenkins_builds/$JOB_NAME/$BUILD_ID"/out/
	fi
	rm -rf "$build_dir"
	echo "Build success at $(date --rfc-3339=seconds)"
else
	rm -rf "$build_dir"
	echo "Build fail at $(date --rfc-3339=seconds)"
	false
fi
