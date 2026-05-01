#!/usr/bin/env bash

_koopa_debian_enable_unattended_upgrades() {
    # """
    # Enable unattended upgrades.
    # @note Updated 2023-05-01.
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
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['dpkg_reconfigure']="$(_koopa_debian_locate_dpkg_reconfigure)"
    app['unattended_upgrades']="$(_koopa_debian_locate_unattended_upgrades)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_debian_apt_install 'apt-listchanges' 'unattended-upgrades'
    _koopa_sudo "${app['dpkg_reconfigure']}" -plow 'unattended-upgrades'
    _koopa_sudo "${app['unattended_upgrades']}" -d
    return 0
}
