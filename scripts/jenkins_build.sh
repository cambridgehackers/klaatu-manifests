#!/bin/bash -ex

if [ -z "$1" ] || [ -z "$WORKSPACE" ]; then
        echo "usage $0 BUILD_SCRIPT BUILD_DIR OUT_DIR"
        exit 1
fi

script="$(dirname $0)/$1"
shift

build_dir="/ramdisk/jenkins_builds/${JOB_NAME}_${BUILD_ID}"

echo "Build start at $(date --rfc-3339=seconds)"

fail=0

rm -f $WORKSPACE/*
if ( "$script" $build_dir ); then
	echo "Build success at $(date --rfc-3339=seconds)"
	out_dir=`find "$build_dir/out/" -name userdata.img`
	if [ -n "$out_dir" ]; then
		out_dir=`dirname "$out_dir"`
		cp -a "$out_dir"/*.*  $WORKSPACE
		tar -zcf $WORKSPACE/system.tar.gz -C "$out_dir" system
		tar -zcf $WORKSPACE/root.tar.gz -C "$out_dir" root
	else
		echo "error userdata.img not found"
		fail=1
	fi
else
	echo "Build fail at $(date --rfc-3339=seconds)"
	fail=1
fi

job_dir="$HOME/jobs/$JOB_NAME/builds/$BUILD_ID"
if [ -f "$build_dir"/.keep ] || ( grep keep "$job_dir"/build.xml | grep -q true ); then
	echo "keeping build directory"
else
	rm -rf "$build_dir"
fi

exit $fail
