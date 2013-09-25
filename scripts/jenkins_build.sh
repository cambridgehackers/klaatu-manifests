#!/bin/bash -ex

for arg in "$@"; do
	case "${arg%%=*}" in
		--build-dir) build_dir="${arg##*=}"; keep=1; shift;;
		--keep) keep=1; shift;;
		*) break;;
	esac
done

if [ -z "$1" ] || [ -z "$WORKSPACE" ]; then
        echo "usage $0 BUILD_SCRIPT [ARGS]"
        echo "Note. This wrapper script is only intended to be used by Jenkins."
        exit 1
fi

script="$(dirname $0)/$1"
shift

rm -rf $WORKSPACE/*

if [ -n "$build_dir" ]; then
	echo using custom build directory: "$build_dir"
elif [ -d /ramdisk ]; then
	# remove past aborted builds
	rm -rf `grep -l ABORTED /ramdisk/jenkins_builds/*/build_job/build.xml | sed 's:/build_job/build.xml$::g'`

	build_dir="/ramdisk/jenkins_builds/${JOB_NAME}_${BUILD_ID}"

	ramdisk_size=`df -m | grep /ramdisk | sed 's:  *: :g' | cut -f2 -d' '`
	if [ -n "$ramdisk_size" ] ; then
		max_builds=$(( $ramdisk_size / 25000 ))
	fi
	rm -rf `ls -1tr $build_dir/ | head -n-$max_builds`
else
	build_dir="$WORKSPACE"/jenkins_build
fi

mkdir -p "$build_dir"
cd "$build_dir"
ln -snf $HOME/jobs/$JOB_NAME/builds/$BUILD_ID build_job

echo "Build start at $(date --rfc-3339=seconds)"

fail=0

if ( "$script" "$@" ); then
	echo "Build success at $(date --rfc-3339=seconds)"
	out_dir=`find "$build_dir/out/" -name userdata.img`
	if [ -n "$out_dir" ]; then
		out_dir=`dirname "$out_dir"`
		find "$out_dir" -maxdepth 1 -type f -exec cp -a '{}' $WORKSPACE ';'
	else
		echo "error userdata.img not found"
		fail=1
	fi
else
	echo "Build fail at $(date --rfc-3339=seconds)"
	fail=1
fi

job_dir="$HOME/jobs/$JOB_NAME/builds/$BUILD_ID"
if [ -n "$keep" ] || [ -f "$build_dir"/.keep ] || ( grep keep "$job_dir"/build.xml | grep -q true ); then
	echo "keeping build directory"
	chmod g+w "$build_dir" || true
	chmod g+w -R "$build_dir"/* || true
else
	rm -rf "$build_dir"
fi

exit $fail
