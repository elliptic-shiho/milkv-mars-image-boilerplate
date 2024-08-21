#!/bin/sh
# SPDX-License-Identifier: MIT

SELF="$(realpath $0)"
BASEDIR="$(dirname ${SELF})"
WORKDIR="${BASEDIR}/work"

if [ ! -f "${BASEDIR}/genimage/genimage" ]; then
    cd "${BASEDIR}/genimage"
    ./autogen.sh
    ./configure
    make -j`nproc`
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
