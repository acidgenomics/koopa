#!/bin/sh

# CPI Azure VM start-up script that runs at reboot.
# Updated 2019-10-31.



# Notes                                                                     {{{1
# ==============================================================================

# Avoid writing our config files into '/etc/' when possible.
# Use '/usr/local/' instead, especially for program installs.
#
# Permissions for '/mnt/' shares are defined in '/etc/fstab'.
# These are set correctly except for '/mnt/resource/', which is fixed below.
#
# Note that some shares on '/mnt/' are Azure Files mounted via CIFS/Samba and
# don't support standard Unix permissions.

# Enable the script to run at reboot.
# > sudo chown root:root /usr/local/etc/reboot.sh
# > sudo chmod 755 /usr/local/reboot.sh
#
# Now enable this in crontab.
# Don't overwrite existing lines there, they're important for authentication.
# > sudo crontab -e
# @reboot /usr/local/koopa/host/azure/config/etc/reboot.sh



# Script                                                                    {{{1
# ==============================================================================

if [ -e "/mnt/resource" ]
then
    chgrp biogroup "/mnt/resource"
    chmod 775 "/mnt/resource"
fi
