#!/bin/bash
# Perform a repo init and also do mirroring behind the scenes
repo_init()
{
  # clear variables that may have been set by a previous invocation
  repo_url=
  repo_urlx=
  repo_name=
  repo_reference=
  branch=
  manifest=
  i=1;
  while [ $i -le $# ];
  do
    case ${!i} in
      -u|--manifest-url) i=$((i+1)); repo_url="${!i}";;
      -b|--manifest-branch) i=$((i+1)); branch="${!i}";;
#      -m|--manifest-name) i=$((i+1)); manifest="${!i}";;
      *) repo_args="$repo_args ${!i}" ;;
    esac
    i=$((i+1))
  done
  repo_urlx="$(echo "$repo_url" | sed 's:^[^/]*//::' | sed 's:^.*@::' | sed 's:\.git$::' | sed 's:/manifest::g' | sed 's:/git::g' | sed 's:[/\.]:_:g')"
  repo_name="${repo_urlx}_${branch}"

  if [ -z "$MIRROR_DIR" ] ; then
    MIRROR_DIR=`dirname $0`/../mirror
    MIRROR_DIR=`realpath "$MIRROR_DIR"`
  fi
  repo_mirror_dir="$MIRROR_DIR/repos"

  if [ ! -d "$repo_mirror_dir/$repo_name" ] ; then
    mkdir -p "$repo_mirror_dir/$repo_name" 
    ( cd "$repo_mirror_dir/$repo_name" ; repo init $@ --mirror ; repo sync -j8 )
  fi

  repo init $@ "--reference=$repo_mirror_dir/$repo_name"
}
