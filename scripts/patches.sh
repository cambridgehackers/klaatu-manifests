#!/bin/bash

# Apply any patches that are applicable to this build
patch_build()
{
  if [ -z "$PATCH_DIR" ] ; then PATCH_DIR=`dirname $0`/../patches ; fi

  build_name="$(basename $0 .sh | sed 's:.*/::g' | sed 's:^build_::g' | sed 's:_:-:g' )"

  #build/target specific patches
  if [ -f "${PATCH_DIR}/${build_name}.series" ]; then
    cat "${PATCH_DIR}/${build_name}.series" | sed "s:^:"${PATCH_DIR}"/:g" | xargs -L1 patch -p0 -i
  elif [ -f "${PATCH_DIR}/${build_name}.patch" ]; then
    patch -p0 < "${PATCH_DIR}/${build_name}.patch"
  fi
}
