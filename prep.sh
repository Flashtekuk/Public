#!/bin/bash
##
#
# apt update ; apt upgrade -y ; curl -4 -o /root/prep.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/prep.sh; chmod +x /root/prep.sh


##
# My personal customisations
#
mkdir -p /root/.ssh -m 0600
echo "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJd2lcSaoR2rpBhonj08A5ouX0EaoIqhzuHcD8rc7TjMHh8qHtCO20mfVl73AXUNGg2hNSDzhMeWHvSGf5au2/4= neil@threadripper" >> /root/.ssh/authorized_keys

groupadd wheel
gpasswd -a neil wheel

sed -i.bak -e 's/# auth       sufficient pam_wheel.so trust/auth       sufficient pam_wheel.so trust/g' /etc/pam.d/su
#
# End of my personal customisations
##

##
# Download webserver-setup.sh
#
curl -o /root/webserver-setup.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/webserver-setup.sh
chmod +x /root/webserver-setup.sh
