#!/bin/bash -e

if [ -z "$1" ]; then
        echo "usage $0 BUILD_SCRIPT BUILD_DIR OUT_DIR"
        exit 1
fi

script="$(dirname $0)/$1"
shift

build_dir="/ramdisk/jenkins_builds/${JOB_NAME}_${BUILD_ID}"

echo "Build start at $(date --rfc-3339=seconds)"

if ( "$script" $build_dir ); then
	mkdir -p "/home/builds/jenkins_builds/$JOB_NAME/$BUILD_ID"/out
	rsync -a --exclude obj $build_dir/out/ "/home/builds/jenkins_builds/$JOB_NAME/$BUILD_ID"/out/
	rm -rf "$build_dir"
	echo "Build success at $(date --rfc-3339=seconds)"
else
	rm -rf "$build_dir"
	echo "Build fail at $(date --rfc-3339=seconds)"
	false
fi
