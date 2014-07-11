#!/bin/bash

include_list=''
klaatu_default_ui=''
stock=''
manifest_paths="$( cd "$( dirname "$0" )"/.. && pwd )/manifests $(pwd)/manifests $(pwd)/manifest/manifests $(pwd)/klaatu-manifests/manifests"

for arg in "$@"; do
  case "$arg" in

  --include-*)
    ui_arg=`echo $arg | sed 's/^--[^\-]*-//'`
    if [ -z "$include_list" ] ; then
      include_list="$ui_arg"
    else
      include_list="$include_list $ui_arg"
    fi
    ;;
  --default-ui=*)
    klaatu_default_ui=`echo $arg | sed 's/^[^=]*=//'`
    ;;
  --manifest-dir=*)
    dir=`echo $arg | sed 's/^[^=]*=//'`
    manifest_paths="$dir $manifest_paths"
    ;;
  --stock)
    stock=yes
    ;;
  esac
done

set_ui_defaults()
{
  if [ -z "$include_list" ] && [ -z "$stock" ] ; then
    include_list="$*"
  fi
}

get_manifests()
{
  klaatu_manifests=''
  if [ -z "$stock" ] ; then include_list_klaatu_common="klaatu-common"; fi

  for name in $include_list $include_list_klaatu_common; do
    xml=
    for dir in $manifest_paths ; do
       if [ -e $dir/${name}.xml ]; then xml=$dir/${name}.xml; break; fi
       if [ -e $dir/klaatu-${name}.xml ]; then xml=$dir/klaatu-${name}.xml; break; fi
    done
    if [ -z "$xml" ]; then
      echo $name not found
      exit 1
    fi
    if [ -z "$klaatu_manifests" ] ; then klaatu_manifests="$xml"
    else klaatu_manifests="$klaatu_manifests $xml"; fi
  done

  echo "$klaatu_manifests"
}

get_default_ui()
{
  for name in $include_list; do
    for dir in $manifest_paths ; do
       if [ -e $dir/klaatu-${name}.xml ]; then
            if [ -z "$klaatu_default_ui" ] ; then klaatu_default_ui="$name"; fi
            break;
       fi
    done
  done
  echo "$klaatu_default_ui"
}
