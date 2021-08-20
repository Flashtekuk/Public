#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
set -e

VER=v8.5.7              # set these 3 lines
NAME=Loadbalancer.org   # change if anything custom (eg. Hologic_lb.org)
IMAGE=image.img         # filename of your current image

## Shouldn't need to edit below here...

if [ $# -ne 1 ]; then
	echo "Usage: ${0} USBName (eg: ${0} sdc)"
	exit 6
else
	USB=${1}
fi

if [[ -b /dev/${USB} ]]; then
	echo "/dev/${USB} is a block device... good."
else
	echo "/dev/${USB} is NOT a block device..."
	exit 8
fi

SIZE=$(fdisk -lu /dev/${USB}|awk '/83/ {print $5}')
NEWSIZE=$(expr ${SIZE} + 2)

dcfldd if=/dev/${USB} of=${IMAGE} bs=512 count=${NEWSIZE}

mkdir Loadbalancer.org\ Enterprise/
mv ${IMAGE} Loadbalancer.org\ Enterprise/${NAME}_${VER}.img
cd Loadbalancer.org\ Enterprise/
md5sum ${NAME}_${VER}.img >${NAME}_${VER}.img.md5
cd ..
zip -r -9 ${NAME}_${VER}.zip Loadbalancer.org\ Enterprise/
md5sum ${NAME}_${VER}.zip >${NAME}_${VER}.zip.md5
