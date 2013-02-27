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

  # defer actual repo init to sync, allowing the creation and use of mirrors with local manifest
  mkdir -p .repo
}

repo_create_overlay()
{
  if [ -f .repo/local_manifest.xml -o -d .repo/local_manifests ] && ( dpkg --compare-versions "$(unionfs -V 2>/dev/null | grep 'unionfs-fuse version' | sed 's:.* ::g')" '>=' '0.26' ) ; then
    mkdir -p "$repo_mirror_dir/overlays/${repo_name}_${build_name}"
    mkdir -p "$repo_mirror_dir/overlays/mnt/${repo_name}_${build_name}"
    if ( ! mount | grep $repo_mirror_dir/overlays/mnt/${repo_name}_${build_name} ); then
      unionfs -o cow,relaxed_permissions $repo_mirror_dir/overlays/${repo_name}_${build_name}=rw:$repo_mirror_dir/${repo_name}=ro $repo_mirror_dir/overlays/mnt/${repo_name}_${build_name} || return false
    fi
    if [ ! -e "$repo_mirror_dir/overlays/mnt/${repo_name}_${build_name}/.repo" ]; then
      ( cd "$repo_mirror_dir/overlays/mnt/${repo_name}_${build_name}"; repo init $repo_init_args -u "$repo_mirror_dir/$repo_name/platform/manifest.git" -b $repo_branch -m $repo_manifest "--reference=$repo_mirror_dir/$repo_name" $repo_args )
    fi
    rm -rf $repo_mirror_dir/overlays/mnt/${repo_name}_${build_name}/.repo/local_manifest*
    cp -a .repo/local_manifest* $repo_mirror_dir/overlays/mnt/${repo_name}_${build_name}/.repo
    ( cd $repo_mirror_dir/overlays/mnt/${repo_name}_${build_name}; time repo sync -j8 )
    return 0
  fi
  return 1
}

repo_sync()
{
  if [ ! -d "$repo_mirror_dir/$repo_name" ] ; then
    mkdir -p "$repo_mirror_dir/$repo_name" 
    ( cd "$repo_mirror_dir/$repo_name" ; repo init $repo_init_args $repo_args -u $mirror_url $mirror_branch -m $repo_manifest --mirror ; time repo sync -j8 )
  fi

  if ( repo_create_overlay ); then
    repo init $repo_init_args -u "$repo_mirror_dir/overlays/mnt/${repo_name}_${build_name}/platform/manifest.git" -b $repo_branch -m $repo_manifest "--reference=$repo_mirror_dir/overlays/mnt/${repo_name}_${build_name}" $repo_args
  else
    repo init $repo_init_args -u "$repo_mirror_dir/$repo_name/platform/manifest.git" -b $repo_branch -m $repo_manifest "--reference=$repo_mirror_dir/$repo_name" $repo_args
  fi

  time repo sync -j8 "$@"
}
