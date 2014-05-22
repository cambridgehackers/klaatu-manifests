#!/bin/bash

for arg in "$@"; do
  case "$arg" in

  --include-*)
    ui_arg=`echo $arg | sed 's/^--include-//'`
    if [ -z "$KLAATU_DEFAULT_UI" ] ; then
      export KLAATU_DEFAULT_UI="$ui_arg"
    fi
    include_arg=`echo "KLAATU_INCLUDE_$ui_arg" | tr [:lower:] [:upper:]`
    export $include_arg=true
    ;;

  --exclude-*)
    exclude_arg=`echo $arg | sed "s/--exclude-\(.*\)/KLAATU_INCLUDE_\1/" | tr [:lower:] [:upper:]`
    export $exclude_arg=false
    ;;

  --default-ui=*)
    ui_arg=`echo $arg | sed 's/^--default-ui=//'`
    export KLAATU_DEFAULT_UI="$ui_arg"
    ;;
  esac
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
