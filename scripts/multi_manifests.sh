#!/bin/bash

for arg in "$@"; do
  include_arg=`echo $arg | grep "^--include" | sed "s/--include-\(.*\)/KLAATU_INCLUDE_\1/" | tr [:lower:] [:upper:]`
  if [ "$include_arg" != "" ]; then
    export $include_arg=true
  fi

  exclude_arg=`echo $arg | grep "^--exclude" | sed "s/--exclude-\(.*\)/KLAATU_INCLUDE_\1/" | tr [:lower:] [:upper:]`
  if [ "$exclude_arg" != "" ]; then
    export $exclude_arg=false
  fi
done

copy_manifests()
{
  need_klaatu_common=false
  mkdir -p .repo/local_manifests
  KLAATU_COMPONENTS=${!KLAATU_INCLUDE_*}
  for arg in $KLAATU_COMPONENTS; do
    if [ `printenv $arg` == true ] ; then
      XML_FILE=`echo $arg | tr [:upper:] [:lower:] | sed "s:klaatu_include_\(.*\):../manifest/manifests/klaatu-\1.xml:"`
      cp $XML_FILE .repo/local_manifests/
      if [ $arg != KLAATU_INCLUDE_ZYGOTE ] ; then
        need_klaatu_common=true
      fi
    fi
  done

  cp ../manifest/manifests/klaatu-init.xml .repo/local_manifests/
  if [ $need_klaatu_common == true ] ; then
    cp ../manifest/manifests/klaatu-headless.xml .repo/local_manifests/
  fi
}
