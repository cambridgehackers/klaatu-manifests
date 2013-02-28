#!/bin/bash

build_name="$(basename $0 .sh | sed 's:.*/::g' | sed 's:^build_::g' | sed 's:_:-:g' )"

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

  if [ ! -d "$MIRROR_DIR"/git-repo.git ]; then
    ( cd "$MIRROR_DIR"; git clone --mirror https://gerrit.googlesource.com/git-repo )
  fi
  repo_init_args="--repo-url $MIRROR_DIR/git-repo.git --repo-branch=stable"
  repo_mirror_dir="$MIRROR_DIR/repos"

  if [ ! -d "$repo_mirror_dir/$repo_name" ] ; then
    mkdir -p "$repo_mirror_dir/$repo_name" 
    ( cd "$repo_mirror_dir/$repo_name" ; repo init $repo_init_args $repo_args -u $mirror_url $mirror_branch -m $repo_manifest --mirror ; time repo sync -j8 )
  fi

  # If there is a local manifest, we'll init again but that's innocuous.
  # We need this initial init so the klaatu builds can modify the manifest.
  repo init $repo_init_args -u "$repo_mirror_dir/$repo_name/platform/manifest.git" -b $repo_branch -m $repo_manifest "--reference=$repo_mirror_dir/$repo_name" $repo_args
}

repo_sync()
{
  if [ -f .repo/local_manifest.xml -o -d .repo/local_manifests -o "$repo_manifest" != "default.xml" ]; then
    # There is/are local manifest(s) or a non-default manifest was used.
    # Bring the mirror up to date before syncing the working directory.
    repo manifest -o "${repo_name}_${build_name}.xml"
    build_dir=`pwd`
    ( cd "$repo_mirror_dir/$repo_name" ; time repo sync -m "$build_dir/${repo_name}_${build_name}.xml" -j8 )
  fi

  time repo sync -j8 "$@"
}
