#!/bin/bash
#set -x

# Script needs root
if [ ${UID} -ne 0 ]; then
    echo "ERROR: ${0} must be run as root user"
    exit 1
fi

# Check for correct number of args (1)
if [ ${#} -ne 1 ]; then
    echo "Usage: ${0} DEVNAME"
    echo "where DEVNAME is the device root node (eg: for /dev/sdc provide 'sdc')"
    exit 2
else
    DISK=${1}
fi

# Check if this is a block device.
if [[ -b /dev/${DISK} ]]; then
    echo "/dev/${DISK} is a block device... good."
else
    echo "/dev/${DISK} is NOT a block device... exiting."
    exit 3
fi

# Install sources
INSTALL_SRC=/mnt/installer
FAT32_SRC=${INSTALL_SRC}/${DISK}1
EXT2_SRC=${INSTALL_SRC}/${DISK}2

echo "Creating needed directories, if needed..."
mkdir -p ${FAT32_SRC} ${EXT2_SRC}

echo "Mounting filesystems..."
mount /dev/${DISK}1 ${FAT32_SRC}
mount /dev/${DISK}2 ${EXT2_SRC}

BASE=usb-installer
FAT32="${BASE}.fat32"
EXT2="${BASE}.ext2"
IMG="${BASE}.img"

echo "Make EFI filesystem file"
truncate -s  512M "${FAT32}"
mkfs -t vfat -n EFIBOOT "${FAT32}"
mcopy -s -v -i "${FAT32}" "${FAT32_SRC}"/* ::/

echo "Make Root filesystem file"
truncate -s 4096M "${EXT2}"
mkfs	-t ext2 \
		-L loadbalancer-usb \
		-m 0 \
		-d "${EXT2_SRC}" \
		"${EXT2}"
resize2fs -M "${EXT2}"

echo "Unmounting the filesystems"
umount ${FAT32_SRC} ${EXT2_SRC}

# Create image.
P1_START=2048
P1_END=+512M # +512MiB
P2_START=0 # Start of available space
P2_END=0 # End of available space

DDOPTS="status=progress conv=sparse,notrunc"

echo "Copying contents of USB image partition 1 to image"
dd ${DDOPTS} if="${FAT32}" of="${IMG}" bs=512 seek=${P1_START}
echo "Copying contents of USB image partition 2 to image"
dd ${DDOPTS} if="${EXT2}"  of="${IMG}" bs=512 seek=${P2_START}

echo "Padding image file to nearest 1GiB"
truncate -s %1G "${IMG}"

echo "Zap the partition table on IMG file"
sgdisk -Z ${IMG}
echo "Create partitions as needed"
sgdisk ${IMG} -n 1:${P1_START}:${P1_END} -t 1:0xEF00 -n 2:${P2_START}:${P2_END} -t 0x8300
echo "Poke the kernel to re-read the partitions"
partprobe

echo "Delete intermediate images..."
rm -v "${EXT2}" "${FAT32}"

echo "Done."
