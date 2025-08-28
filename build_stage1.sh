#!/bin/sh
# SPDX-License-Identifier: MIT
set -e

SELF="$(realpath $0)"
BASEDIR="$(dirname ${SELF})"
WORKDIR="${BASEDIR}/work"

if [ ! -d "${WORKDIR}" ]; then
    /bin/mkdir "${WORKDIR}"
fi

# Patching u-boot (macOS only)
if [ "`uname`" == "Darwin" ]; then 
  if [ ! -f "${BASEDIR}/u-boot/.patched" ]; then
    cd "${BASEDIR}/u-boot"
    patch -p1 < "${BASEDIR}/patches/u-boot-mac.patch"
    touch .patched
  fi
  if [ ! -f "${BASEDIR}/Tools/.patched" ]; then
    cd "${BASEDIR}/Tools"
    patch -p1 < "${BASEDIR}/patches/spl_tool-mac.patch"
    touch .patched
  fi
  if [ ! -f "${BASEDIR}/Tools/spl_tool/endian.h" ]; then
    wget https://gist.githubusercontent.com/yinyin/2027912/raw/6b3e394dc6a37817410d66d6ba4d7cd6b8d5d03d/endian.h -O "${BASEDIR}/Tools/spl_tool/endian.h"
  fi
  export NCPU=`sysctl -n hw.ncpu`
else
  export NCPU=`nproc`
fi

export ARCH=riscv
export CROSS_COMPILE=riscv64-linux-

# Build u-boot
cd "${BASEDIR}/u-boot"
make starfive_visionfive2_defconfig
make -j"$NCPU"

# Make SPL image
cd "${BASEDIR}/Tools/spl_tool"
make
./spl_tool -c -f "${BASEDIR}/u-boot/spl/u-boot-spl.bin"

# Build OpenSBI
cd "${BASEDIR}/opensbi"
PLATFORM=generic FW_PAYLOAD_PATH="${BASEDIR}/u-boot/u-boot.bin" FW_FDT_PATH="${BASEDIR}/u-boot/arch/riscv/dts/starfive_visionfive2.dtb" FW_TEXT_START=0x40000000 make -j"$NCPU"


cp "${BASEDIR}/Tools/uboot_its/visionfive2-uboot-fit-image.its" "${WORKDIR}"
cp "${BASEDIR}/opensbi/build/platform/generic/firmware/fw_payload.bin" "${WORKDIR}"
cp "${BASEDIR}/u-boot/spl/u-boot-spl.bin.normal.out" "${WORKDIR}"

cd "${WORKDIR}"
${BASEDIR}/u-boot/tools/mkimage -f visionfive2-uboot-fit-image.its -A riscv -O u-boot -T firmware vf2_fw_payload.img
