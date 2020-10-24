#!/bin/bash
##
#
# apt update ; apt upgrade -y ; curl -4 -o /root/prep.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/prep.sh; chmod +x /root/prep.sh

##
# Install packages
#
apt install -y screen rsync htop curl

##
# My personal customisations
#
mkdir -p /root/.ssh -m 0600
echo "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBJd2lcSaoR2rpBhonj08A5ouX0EaoIqhzuHcD8rc7TjMHh8qHtCO20mfVl73AXUNGg2hNSDzhMeWHvSGf5au2/4= neil@threadripper" >> /root/.ssh/authorized_keys
echo "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCcrLX1MVmzCsxz7KiHyjdICZU91hnrok5IY9E6kIoZK0Q379xiNEYuGSBCuitZcumYd41bra+hyaM/pQMBMb1A= neil@IntTest1" >> /root/.ssh/authorized_keys

groupadd wheel
gpasswd -a neil wheel

sed -i.bak -e 's/# auth       sufficient pam_wheel.so trust/auth       sufficient pam_wheel.so trust/g' /etc/pam.d/su

echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'" >> /root/.bashrc

#
# End of my personal customisations
##

##
# Download webserver-setup.sh
#
curl -o /root/webserver-setup.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/webserver-setup.sh
curl -o /root/post.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/post.sh
chmod +x /root/*.sh
