#!/bin/sh

# CPI Azure VM start-up script that runs at reboot.
# Updated 2019-11-03.

# Avoid writing our config files into '/etc/' when possible.
# Use '/usr/local/' instead, especially for program installs.
#
# Permissions for '/mnt/' shares are defined in '/etc/fstab'.
# These are set correctly except for '/mnt/resource/', which is fixed below.
#
# Note that some shares on '/mnt/' are Azure Files mounted via CIFS/Samba and
# don't support standard Unix permissions.
#
# Now enable this in crontab.
# Don't overwrite existing lines there, they're important for authentication.
# > sudo crontab -e
# @reboot /usr/local/koopa/host/azure/config/etc/reboot.sh

if [ -e "/mnt/resource" ]
then
    chown root:root "/mnt/resource"
    chmod 1777 "/mnt/resource"
fi
