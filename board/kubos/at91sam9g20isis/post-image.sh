#!/bin/sh

BOARD_DIR="$(dirname $0)"
CURR_DIR="$(pwd)"
BRANCH=$2
OUTPUT=$(basename ${BASE_DIR})

GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

# Create the kernel FIT file
cp ${BOARD_DIR}/kubos-kernel.its ${BINARIES_DIR}/
cd ${BR2_EXTERNAL_KUBOS_LINUX_PATH}/tools
./kubos-kernel.sh -b ${BRANCH} -i ${BINARIES_DIR}/kubos-kernel.its -o ${OUTPUT}

mv kubos-kernel.itb ${BINARIES_DIR}/kernel

# Create the base upgrade file
cd ${BR2_EXTERNAL_KUBOS_LINUX_PATH}/tools
./kubos-package.sh -b ${BRANCH} -t at91sam9g20isis -v base -i ${BOARD_DIR}/kpack.its

mv kpack-base.itb ${TARGET_DIR}/upgrade

cd ${CURR_DIR}

# Generate the images
genimage \
    --rootpath "${TARGET_DIR}" \
    --tmppath "${GENIMAGE_TMP}" \
    --inputpath "${BINARIES_DIR}" \
    --outputpath "${BINARIES_DIR}" \
    --config "${GENIMAGE_CFG}"

# Package it up for easy transfer
tar -czf ${BINARIES_DIR}/kubos-linux.tar.gz -C ${BINARIES_DIR} kubos-linux.img

# Clean up
rm ${TARGET_DIR}/upgrade/*

# Removing these just to free up disk space...
rm ${BINARIES_DIR}/user
rm ${BINARIES_DIR}/upgrade
rm ${BINARIES_DIR}/kubos-linux.img