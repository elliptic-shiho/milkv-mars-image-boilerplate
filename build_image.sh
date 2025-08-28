#!/bin/sh
# SPDX-License-Identifier: MIT

SELF="$(realpath $0)"
BASEDIR="$(dirname ${SELF})"
WORKDIR="${BASEDIR}/work"

if [ "`uname`" == "Darwin" ]; then 
  if [ ! -f "${BASEDIR}/genimage/endian.h" ]; then
    wget https://gist.githubusercontent.com/yinyin/2027912/raw/6b3e394dc6a37817410d66d6ba4d7cd6b8d5d03d/endian.h -O "${BASEDIR}/genimage/endian.h"
  fi

  if [ ! -f "${BASEDIR}/genimage/.patched" ]; then
    cd "${BASEDIR}/genimage"
    patch -p1 < "${BASEDIR}/patches/genimage-mac.patch"
    touch .patched
  fi

  export NCPU=`sysctl -n hw.ncpu`
else
  export NCPU=`nproc`
fi

if [ ! -f "${BASEDIR}/genimage/genimage" ]; then
    cd "${BASEDIR}/genimage"
    autoreconf -fi
    ./autogen.sh
    CC=gcc CFLAGS="-D_GNU_SOURCE" ./configure
    make -j"$NCPU"
fi

cd "${BASEDIR}"

IMGPATH="${BASEDIR}/work/main.img"

dd if=/dev/zero of="${IMGPATH}" bs=1M count=8
mkfs.vfat "${IMGPATH}"
mcopy -i "${IMGPATH}" "${BASEDIR}/vf2_uEnv.txt" ::vf2_uEnv.txt

ROOTPATH="$(mktemp -d)"
TMPPATH="$(mktemp -d)"
${BASEDIR}/genimage/genimage --config "${BASEDIR}/genimage.cfg" --outputpath "${BASEDIR}" --rootpath "$ROOTPATH" --tmppath "$TMPPATH" --inputpath "${BASEDIR}"
rm -rf "$ROOTPATH"
rm -rf "$TMPPATH"
