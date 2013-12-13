#!/bin/bash -el
# get vendor build, and print xml of created git repo

[ -n "$1" ] || exit 1

build=$1

mirror_dir1="$( cd "$(dirname "$0")/.."; pwd)/mirror"
mirror_dir2="$HOME/mirror"
if [ -z "$MIRROR_DIR" ] ; then
  if [ -d "$mirror_dir1" ]; then MIRROR_DIR="$mirror_dir1"
  elif [ -d "$mirror_dir2" ]; then MIRROR_DIR="$mirror_dir2"
  else echo "please create directory or link: $mirror_dir1 or $mirror_dir2"; exit 1
  fi
fi

if [ -f $MIRROR_DIR/vendor/vendor-$build.xml ]; then
	echo $MIRROR_DIR/vendor/vendor-$build.xml
	exit 0
fi

mkdir -p $MIRROR_DIR/vendor
cd $MIRROR_DIR/vendor

mkdir tmp

#wget each link for build id, and untar
for a in `wget --quiet -O- https://developers.google.com/android/nexus/drivers | grep -io 'https\?:[^"]*'"$build"'[^"]*'`; do wget --quiet -O- $a | tar -C tmp -xz; done 

#extract each file, skipping to gzip header in shar first
for s in tmp/extract*sh; do tail -c +`grep -obaP '\x1f\x8b' < $s|head -n 1|grep -o '[0-9]*'` $s|tail -c +2|tar -xz; done 

# commit to local git repo and create reference manifest 
mv vendor vendor-$build
vendor_dir=`pwd`/vendor-$build
( cd vendor-$1; git init; git add *; git commit --quiet -m "vendor build $1" ) 1>&2
cat <<EOF >vendor-$1.xml
<manifest>
  <remote name="vendor" fetch="file://$vendor_dir" />
  <project path="vendor" name="." remote="vendor" revision="master"/>
</manifest>
EOF

rm -rf tmp

echo `pwd`/vendor-$build.xml
