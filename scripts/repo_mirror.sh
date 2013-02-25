#!/bin/bash
# Perform a repo init and also do mirroring behind the scenes
repo_init()
{
  # clear variables that may have been set by a previous invocation
  repo_url=
  repo_urlx=
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

  repo_urlx="$(echo "$repo_url" | sed 's:^[^/]*//::' | sed 's:^.*@::' | sed 's:\.git$::' | sed 's:/manifest::g' | sed 's:/git::g' | sed 's:[/\.]:_:g')"
  repo_name="${repo_urlx}_${repo_branch}"

  if [ "$repo_url" == "https://android.googlesource.com/platform/manifest" ] ; then
    # we only need a single mirror for all AOSP branches
    mirror_url="https://android.googlesource.com/mirror/manifest"
    repo_name="$repo_urlx"
  else
    mirror_url=$repo_url
    mirror_branch="-b $repo_branch"
  fi

  if [ -z "$MIRROR_DIR" ] ; then
    MIRROR_DIR=`dirname $0`/../mirror
    MIRROR_DIR=`realpath "$MIRROR_DIR"`
  fi
  repo_mirror_dir="$MIRROR_DIR/repos"

  # defer actual repo init to sync, allowing the creation and use of mirrors with local manifest
  mkdir -p .repo
}

repo_sync()
{
  if [ ! -d "$repo_mirror_dir/$repo_name" ] ; then
    mkdir -p "$repo_mirror_dir/$repo_name" 
    ( cd "$repo_mirror_dir/$repo_name" ; repo init $repo_args -u $mirror_url $mirror_branch -m $manifest --mirror ; repo sync -j8 )
  fi

  repo init -u "$repo_mirror_dir/$repo_name/platform/manifest.git" -b $repo_branch -m $repo_manifest "--reference=$repo_mirror_dir/$repo_name" $repo_args

  time repo sync -j8 "$@"
}
