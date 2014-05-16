#!/bin/bash

let i=1
for arg in "$@"; do
  let i=$i+1
  if [ "$skip_next" == "true" ]; then
    skip_next=false
    continue
  fi

  include_arg=`echo $arg | grep "^--include" | sed "s/--include-\(.*\)/KLAATU_INCLUDE_\1/" | tr [:lower:] [:upper:]`
  if [ "$include_arg" != "" ]; then
    export $include_arg=true
  fi

  exclude_arg=`echo $arg | grep "^--exclude" | sed "s/--exclude-\(.*\)/KLAATU_INCLUDE_\1/" | tr [:lower:] [:upper:]`
  if [ "$exclude_arg" != "" ]; then
    export $exclude_arg=false
  fi

  if [ "$arg" == "--default-ui" ]; then
    if [ $i -gt $# ]; then
      echo Missing parameter to --default-ui
      exit -1
    fi
    export KLAATU_DEFAULT_UI=${!i}
    skip_next=true
  fi
done

copy_manifests()
{
  mkdir -p .repo/local_manifests
  export KLAATU_COMPONENTS=${!KLAATU_INCLUDE_*}
  for arg in $KLAATU_COMPONENTS; do
    if [ `printenv $arg` == true ] ; then
      XML_FILE=`echo $arg | tr [:upper:] [:lower:] | sed "s:klaatu_include_\(.*\):../manifest/manifests/klaatu-\1.xml:"`
      cp $XML_FILE .repo/local_manifests/
    fi
  done

  cp ../manifest/manifests/klaatu-common.xml .repo/local_manifests/
}
