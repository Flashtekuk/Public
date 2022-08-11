#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# find / -type f -or -type d -exec stat -c '%n %U %G %a' {} \; | sed -e "s:\ :\,:g"
# find /bin /boot /etc /home /lib /lib64 /opt /root /sbin /tmp /usr /var  -type f -or -type d -exec stat -c '%n %U %G %a' {} \; | sed -e "s:\ :\,:g" > perms.csv

LIST="$(cat perms.csv)"

for ROW in ${LIST}; do
	echo ${ROW} | awk 'BEGIN { FS = "," } ; { system("echo chown " $2 ":" $3 " " $1)} ; { system("echo chmod " $4 " " $1)}'
done
