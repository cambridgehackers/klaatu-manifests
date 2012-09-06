#!/bin/bash
set -x

export SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
LOCAL_MANIFEST=$2

case $1 in 
4.0.3orig)
    # this is the zip file that matches the manifest closest
     $SCRIPT_DIR/fullbuildq ics_chocolate M8960AAAAANLYA1031A.xml $LOCAL_MANIFEST/cambridge-vendor-4.0.3.xml
    #### hy11-n4705-26.zip
    source build/envsetup.sh
    choosecombo 2 msm8960 eng
    make -j33
    ;;

4.0.3)
    # this is the manifest that matches the zip file
    $SCRIPT_DIR/fullbuildq ics_chocolate_rb1 M8960AAAAANLYA1032.xml $LOCAL_MANIFEST/cambridge-vendor-4.0.3.xml
    #### hy11-n4705-26.zip
    source build/envsetup.sh
    choosecombo 2 msm8960 eng
    make -j33
    ;;

4.1.1)
    $SCRIPT_DIR/fullbuildq release M8960AAAAANLYA2004.xml $LOCAL_MANIFEST/cambridge-vendor-4.1.1.xml
    #### hy11-nc697-2.zip
    source build/envsetup.sh
    choosecombo 2 msm8960 eng
    make -j33
    ;;

2.3.6)
    #2.3.6 2.6.38.6 GRK39F gingerbread_chocolate M76XXUSNEKNLYA1610.xml
    # this seems closest to the S6500 build
    $SCRIPT_DIR/fullbuildq gingerbread_chocolate M76XXUSNEKNLYA1610.xml $LOCAL_MANIFEST/cambridge-vendor-2.3.6.xml
    #### HY11-NB914-1.zip
    source build/envsetup.sh
    choosecombo 1 1 msm7627a user
    make -j33
    ;;
esac
$SCRIPT_DIR/buildrpm
