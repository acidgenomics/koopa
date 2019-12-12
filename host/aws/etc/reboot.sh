#!/bin/sh

# CPI Azure VM start-up script that runs at reboot.
# Updated 2019-12-05.
#
# Permissions for '/mnt/' shares are defined in '/etc/fstab'.
# These are set correctly except for '/mnt/resource/', which is fixed below.
#
# Note that some shares on '/mnt/' are Azure Files mounted via CIFS/Samba and
# don't support standard Unix permissions.

if [ -e /mnt/resource ]
then
    chown root:root /mnt/resource
    chmod 1777 /mnt/resource
    sudo ln -fnsv /mnt/resource /tmp/rstudio-tmp
fi
