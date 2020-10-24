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

groupadd wheel
gpasswd -a neil wheel

sed -i.bak -e 's/# auth       sufficient pam_wheel.so trust/auth       sufficient pam_wheel.so trust/g' /etc/pam.d/su

cat << EOF > /root/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'

EOF

#
# End of my personal customisations
##

##
# Download webserver-setup.sh
#
curl -o /root/webserver-setup.sh https://raw.githubusercontent.com/Flashtekuk/Public/master/webserver-setup.sh
chmod +x /root/webserver-setup.sh
