#!/usr/bin/env bash

# FIXME Need to harden sudo and dpkg-reconfigure commands here.

koopa::debian_enable_unattended_upgrades() { # {{{1
    # """
    # Enable unattended upgrades.
    # @note Updated 2021-06-11.
    #
    # @seealso
    # - https://wiki.debian.org/UnattendedUpgrades
    # - https://blog.confirm.ch/unattended-upgrades-in-debian/
    #
    # Default config:
    # - /etc/apt/apt.conf.d/50unattended-upgrades
    # - /etc/apt/apt.conf.d/20auto-upgrades
    #
    # Logs:
    # - /var/log/dpkg.log
    # - /var/log/unattended-upgrades/
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'dpkg-reconfigure'
    koopa::debian_apt_install 'apt-listchanges' 'unattended-upgrades'
    # The file '/etc/apt/apt.conf.d/20auto-upgrades' can be created manually or
    # by running the following command as root.
    sudo dpkg-reconfigure -plow 'unattended-upgrades'
    # Check status.
    sudo unattended-upgrades -d
    return 0
}

