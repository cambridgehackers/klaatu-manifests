#
gzip frameworks/base/libs/rs/Android.mk
sed -i.001 -e "/^include/d" build/target/product/sdk.mk
sed -i.001 -e "/^droidcore: /s/doc-comment-check-docs//" frameworks/base/Android.mk
sed -i.001 -e "/^DEFAULT_HTTP = /s/chrome/notchrome/" frameworks/base/media/libstagefright/Android.mk
