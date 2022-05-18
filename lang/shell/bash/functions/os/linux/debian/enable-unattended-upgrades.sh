#!/usr/bin/env bash

koopa_debian_enable_unattended_upgrades() {
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
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [dpkg_reconfigure]="$(koopa_debian_locate_dpkg_reconfigure)"
        [sudo]="$(koopa_locate_sudo)"
        [unattended_upgrades]="$(koopa_debian_locate_unattended_upgrades)"
    )
    koopa_debian_apt_install 'apt-listchanges' 'unattended-upgrades'
    # The file '/etc/apt/apt.conf.d/20auto-upgrades' can be created manually or
    # by running the following command as root.
    "${app[sudo]}" "${app[dpkg_reconfigure]}" -plow 'unattended-upgrades'
    # Check status.
    "${app[sudo]}" "${app[unattended_upgrades]}" -d
    return 0
}
