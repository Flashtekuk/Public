# images
Scripts to automate the generation of Loadbalancer.org VM images

README.md - This file

mk-vm-image.sh - workstation script to initiate build process, must be run from within appropriate git repo

config_step1.sh - Performs initial cleanup and reconfiguration of remote system, ready for step2

config_step2.sh - Full clean up of appliance, zero pad disk, shutdown etc.
