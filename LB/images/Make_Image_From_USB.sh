#!/bin/bash -e
PATH=/bin:/sbin:/usr/bin:/usr/sbin

#
# Make_Image_From_USB.sh - Create an image file from USB stick to faciliate hardware install
#

IMG_NAME=image.img

# Check for correct number of args
if [ ${#} -ne 1 ]; then
    echo "Usage: ${0} DEVNAME"
    echo "where DEVNAME is the device root node (eg: /dev/sdc)"
    exit 2
else
    DISK=${1}
fi

# Check if this is a block device.
if [[ -b /dev/${DISK} ]]; then
    echo "/dev/${DISK} is a block device... good."
else
    echo "/dev/${DISK} is NOT a block device... exiting."
    exit 8
fi

echo "############################# STARTING #######################################"
echo "Ripping: /dev/${DISK}1 to file ${DISK}1"
dd status=progress if=/dev/${DISK}1 of=${DISK}1
echo "Ripping: /dev/${DISK}2 to file ${DISK}2"
dd status=progress if=/dev/${DISK}2 of=${DISK}2
echo "##############################################################################"

# Set vars to file sizes.
PART1_SIZE=$(du --apparent-size -B 512 ${DISK}1 | awk '{print $1}' )
PART2_SIZE=$(du --apparent-size -B 512 ${DISK}2 | awk '{print $1}' )

DISK_SIZE=$(( ${PART1_SIZE} + ${PART2_SIZE} ))

IMG_SIZE=$(( (${DISK_SIZE} + 16 + 10240) * 512 ))

echo "Creating a blank file to be used for the image."
truncate -s ${IMG_SIZE} ${IMG_NAME}
echo "##############################################################################"

echo "Creating a loopback device from the image file."
losetup -fP ${IMG_NAME}
LO_IMG=$(losetup -l | grep ${IMG_NAME} | awk '{print $1}')
echo "##############################################################################"

echo "Replicating /dev/${DISK} partition table to ${LO_IMG}"
sgdisk --replicate=${LO_IMG} /dev/${DISK}
echo "##############################################################################"

echo "Copying ${DISK}1 to ${LO_IMG}1"
dd status=progress if=${DISK}1 of=${LO_IMG}p1
echo "Copying ${DISK}2 to ${LO_IMG}2"
dd status=progress if=${DISK}2 of=${LO_IMG}p2
sync
echo "##############################################################################"

echo "Cleaning up..."
echo "##############################################################################"
losetup -d ${LO_IMG}
rm -vf ${DISK}1 ${DISK}2

echo "####################################### END ##################################"

exit 0
