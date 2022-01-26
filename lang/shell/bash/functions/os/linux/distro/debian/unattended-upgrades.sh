#!/usr/bin/env bash

koopa::debian_enable_unattended_upgrades() { # {{{1
    # """
    # Enable unattended upgrades.
    # @note Updated 2021-11-02.
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
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [dpkg_reconfigure]="$(koopa::debian_locate_dpkg_reconfigure)"
        [sudo]="$(koopa::locate_sudo)"
        [unattended_upgrades]="$(koopa::debian_locate_unattended_upgrades)"
    )
    koopa::debian_apt_install 'apt-listchanges' 'unattended-upgrades'
    # The file '/etc/apt/apt.conf.d/20auto-upgrades' can be created manually or
    # by running the following command as root.
    "${app[sudo]}" "${app[dpkg_reconfigure]}" -plow 'unattended-upgrades'
    # Check status.
    "${app[sudo]}" "${app[unattended_upgrades]}" -d
    return 0
}
