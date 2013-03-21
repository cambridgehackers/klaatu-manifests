#
#~/klaatu-manifests/scripts/fullbuildt master rowboat-gingerbread.xml
#~/klaatu-manifests/scripts/fullbuildt master rowboat-jb.xml
~/klaatu-manifests/scripts/fullbuildt master rowboat-gingerbread.xml
export TARGET_PRODUCT=beagleboard
export OMAPES=3.x
#make -j33 TARGET_PRODUCT=${KLAATU_PRODUCT} OMAPES=3.x
make

