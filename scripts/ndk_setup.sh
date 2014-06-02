#!/bin/bash

if [ -z "$MIRROR_DIR" ]; then
  MIRROR_DIR="$(dirname "$(cd "$(dirname "$0")" && pwd)")/mirror"
fi

# Pull down the NDK from Googlesource or local mirror, create a standalone
# compiler, and add it to the PATH
setup_ndk()
{
  if [ ! -d "$MIRROR_DIR"/ndk ]; then
    ( flock -x 9; mkdir -p "$MIRROR_DIR"/ndk; cd "$MIRROR_DIR"/ndk; curl http://dl.google.com/android/ndk/android-ndk-r8e-linux-x86_64.tar.bz2 | tar jxf -) 9>"$MIRROR_DIR/ndk.lock"
  fi

  if [ ! -d "$MIRROR_DIR"/ndk_toolchain ]; then
    ( flock -x 9; cd "$MIRROR_DIR"/ndk/android-ndk-r8e/build/tools ; ./make-standalone-toolchain.sh --toolchain=arm-linux-androideabi-4.4.3 --install-dir="$MIRROR_DIR"/ndk_toolchain --platform=android-14 --ndk-dir="$MIRROR_DIR"/ndk/android-ndk-r8e --system=linux-x86_64) 9>"$MIRROR_DIR/ndk.lock"
  fi

  if [[ ":$PATH:" != *":$MIRROR_DIR/ndk_toolchain/bin:"* ]]; then
    export PATH="$PATH":"$MIRROR_DIR"/ndk_toolchain/bin
    export KLAATU_NDK=$MIRROR_DIR/ndk/android-ndk-r8e
  fi
}

setupStandaloneCompiler() {
  setup_ndk "$@"
}
