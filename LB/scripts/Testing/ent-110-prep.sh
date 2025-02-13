#!/bin/bash
set -e
set -x

UPDATE=${1:-lb_update.8.777.14-1.lb.tar.gz}
VERSION=${2:-$(echo ${UPDATE}|awk -F. '{print $2"."$3"."$4"."$5}')}

echo "Extracting ${UPDATE}"
tar xf ${UPDATE}

echo "Making default-valid"
cp ~/Testing/ENT-110/Default/InstallHook.class.php* lb_update/${VERSION}/inc/classes/lb/update/
tar czf default-valid-${VERSION}.tar.gz lb_update

echo "Making default-invalid"
echo "// INVALIDATE SIGNATURE" >> lb_update/${VERSION}/inc/classes/lb/update/InstallHook.class.php
tar czf default-invalid-${VERSION}.tar.gz lb_update

echo "Making stop-valid"
cp ~/Testing/ENT-110/Stop-install/InstallHook.class.php* lb_update/${VERSION}/inc/classes/lb/update/
tar czf stop-valid-${VERSION}.tar.gz lb_update

echo "Making stop-invalid"
echo "// INVALIDATE SIGNATURE" >> lb_update/${VERSION}/inc/classes/lb/update/InstallHook.class.php
tar czf stop-invalid-${VERSION}.tar.gz lb_update

echo "Making proceed-valid"
cp ~/Testing/ENT-110/Proceed-install/InstallHook.class.php* lb_update/${VERSION}/inc/classes/lb/update/
tar czf proceed-valid-${VERSION}.tar.gz lb_update

echo "Making proceed-invalid"
echo "// INVALIDATE SIGNATURE" >> lb_update/${VERSION}/inc/classes/lb/update/InstallHook.class.php
tar czf proceed-invalid-${VERSION}.tar.gz lb_update

echo "Making checksums..."
for archive in *.gz; do md5sum ${archive}|awk '{print $1}' > ${archive}.md5 ; done

echo "Done, now put these somewhere useful..."
