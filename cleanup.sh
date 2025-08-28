#!/bin/sh
# SPDX-License-Identifier: MIT
set -e

SELF="$(realpath $0)"
BASEDIR="$(dirname ${SELF})"

if [ -f "${BASEDIR}/u-boot/.patched" ]; then
  cd "${BASEDIR}/u-boot"
  rm -rf *
  rm .patched
  git reset --hard
fi

if [ -f "${BASEDIR}/Tools/.patched" ]; then
  cd "${BASEDIR}/Tools"
  rm -rf *
  rm .patched
  git reset --hard
fi

if [ -f "${BASEDIR}/genimage/.patched" ]; then
  cd "${BASEDIR}/genimage"
  rm -rf *
  rm .patched
  git reset --hard
fi

