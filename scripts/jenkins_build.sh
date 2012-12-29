#!/bin/sh

if [ -z "$1" ]; then
        echo "usage $0 BUILD_SCRIPT BUILD_DIR OUT_DIR"
        exit 1
fi

script=$1
shift

build_dir=/ramdisk/jenkins_builds/$JOB_NAME/$BUILD_ID

echo "Build start at $(date --rfc-3339=seconds)"
if ( "$(dirname $0)/$script" $build_dir ); then
	echo "Build success at $(date --rfc-3339=seconds)"
	mkdir -p /home/builds/jenkins_builds/$JOB_NAME/$BUILD_ID
	cp -a $build_dir/out /home/builds/jenkins_builds/$JOB_NAME/$BUILD_ID
	rm -rf $build_dir
else
	echo "Build fail at $(date --rfc-3339=seconds)"
	rm -rf $build_dir
	false
fi
