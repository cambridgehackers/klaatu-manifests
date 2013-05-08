#!/bin/bash
[ -z "$NUM_CPUS" ] && export NUM_CPUS=`sysctl  -n hw.ncpu 2>/dev/null || grep processor -c /proc/cpuinfo`

build_name="$(basename $0 .sh | sed 's:.*/::g' | sed 's:^build_::g' | sed 's:_:-:g' )"

for arg in "$@"; do
  if [ "$arg" = "--no-mirror-sync" ]; then
    repo_no_mirror_sync=1
  fi
done

# Perform a repo init and also do mirroring behind the scenes
repo_init()
{
  # clear variables that may have been set by a previous invocation
  repo_url=
  repo_name_short=
  repo_name=
  repo_branch=master
  repo_manifest=default.xml
  repo_args=
  i=1;
  while [ $i -le $# ];
  do
    case ${!i} in
      -u|--manifest-url) i=$((i+1)); repo_url="${!i}";;
      -b|--manifest-branch) i=$((i+1)); repo_branch="${!i}";;
      -m|--manifest-name) i=$((i+1)); repo_manifest="${!i}";;
      *) repo_args="$repo_args ${!i}" ;;
    esac
    i=$((i+1))
  done

  repo_name_short="$(echo "$repo_url" | sed 's:^[^/]*//::' | sed 's:^.*@::' | sed 's:\.git$::' | sed 's:/manifest::g' | sed 's:/git::g' | sed 's:[/\.]:_:g')"
  repo_name="${repo_name_short}_${repo_branch}"
  repo_name_full="$repo_name"
  if [ "$repo_branch" != "default.xml" ]; then 
    repo_name_full="${repo_name}_$(basename $repo_manifest .xml)"
  fi

  if [ "$repo_url" == "https://android.googlesource.com/platform/manifest" ] ; then
    # we only need a single mirror for all AOSP branches
    mirror_url="https://android.googlesource.com/mirror/manifest"
    repo_name="$repo_name_short"
  else
    mirror_url=$repo_url
    mirror_branch="-b $repo_branch"
  fi

  if [ -z "$MIRROR_DIR" ] ; then
    MIRROR_DIR=`dirname $0`/../mirror
    MIRROR_DIR=`realpath "$MIRROR_DIR"`
  fi

  if [ ! -d "$MIRROR_DIR"/git-repo.git ]; then
    ( cd "$MIRROR_DIR"; git clone --mirror https://gerrit.googlesource.com/git-repo )
  fi
  repo_init_args="--repo-url file://$MIRROR_DIR/git-repo.git --repo-branch=stable"
  repo_mirror_dir="$MIRROR_DIR/repos"

  if [ -z "$repo_no_mirror_sync" ] && [ ! -d "$repo_mirror_dir/$repo_name" ] ; then
    mkdir -p "$repo_mirror_dir/$repo_name" 
    ( flock -x 9; cd "$repo_mirror_dir/$repo_name" ; repo init $repo_init_args $repo_args -u $mirror_url $mirror_branch -m $repo_manifest --mirror -p all ; time repo sync -j${NUM_CPUS} ) 9>"$repo_mirror_dir/$repo_name/repo.lock"
  fi

  # if we can find a local copy of the manifest.git, use it.
  if [ -d "$repo_mirror_dir/$repo_name/platform/manifest.git" ] ; then
    repo_url="$repo_mirror_dir/$repo_name/platform/manifest.git"
  elif [ -d "$repo_mirror_dir/$repo_name/manifest.git" ] ; then
    repo_url="$repo_mirror_dir/$repo_name/manifest.git"
  fi

  # If there is a local manifest, we'll init again but that's innocuous.
  # We need this initial init so the klaatu builds can modify the manifest.
  repo init $repo_init_args -u "$repo_url" -b $repo_branch -m $repo_manifest "--reference=$repo_mirror_dir/$repo_name" $repo_args
}

repo_sync()
{
  if [ -z "$repo_no_mirror_sync" ] && [ -f .repo/local_manifest.xml -o -d .repo/local_manifests -o "$repo_manifest" != "default.xml" ]; then
    # There is/are local manifest(s) or a non-default manifest was used.
    # Bring the mirror up to date before syncing the working directory.
    repo manifest -o "${repo_name}_${build_name}.xml"
    build_dir=`pwd`
    ( flock -x 9; cd "$repo_mirror_dir/$repo_name" ; time repo sync -m "$build_dir/${repo_name}_${build_name}.xml" -j${NUM_CPUS} ) 9>"$repo_mirror_dir/$repo_name/repo.lock"
  fi

  time repo sync -j${NUM_CPUS} "$@"
}