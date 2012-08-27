#!/bin/bash

set -x
REFERENCE_DIR=$1
RELEASE_EXTENSION=img.ext4
../klaatu-manifests/tools/unbootimg.py boot.img
mkbootimg --kernel tmp.kernel --ramdisk tmp.ramdisk.gz --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=31' --pagesize 2048 --base 0x80200000 -o foo
simg2img system.$RELEASE_EXTENSION tmp.system
simg2img cache.$RELEASE_EXTENSION tmp.cache
simg2img tombstones.$RELEASE_EXTENSION tmp.tombstones
simg2img userdata.$RELEASE_EXTENSION tmp.userdata
[ -e s ] || mkdir s c t u b
(cd b; gunzip -c ../tmp.ramdisk.gz | cpio -idm)
sudo mount -o loop tmp.system s
sudo mount -o loop tmp.cache c
sudo mount -o loop tmp.tombstones t
sudo mount -o loop tmp.userdata u
rm -rf copy; mkdir copy
sudo tar cf - s c t u b | (cd copy; tar xf -)
sudo umount s c t u
rmdir s c t u
cmp $REFERENCE_DIR/out/target/product/*/kernel tmp.kernel
diff -r $REFERENCE_DIR/out/target/product/*/root copy/b/ >xx.diff.b
diff -r $REFERENCE_DIR/out/target/product/*/system copy/s >xx.diff.s
diff -r $REFERENCE_DIR/out/target/product/*/tombstones copy/t >xx.diff.t
diff -r $REFERENCE_DIR/out/target/product/*/data copy/u >xx.diff.u
diff -r $REFERENCE_DIR/out/target/product/*/cache copy/c >xx.diff.c
wc xx.diff*
rm -rf b tmp.system tmp.cache tmp.tombstones tmp.userdata tmp.ramdisk.gz tmp.kernel
