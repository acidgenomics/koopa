#!/usr/bin/env bash

koopa_debian_locate_apt() {
    koopa_locate_app '/usr/bin/apt'
}

koopa_debian_locate_apt_get() {
    koopa_locate_app '/usr/bin/apt-get'
}

koopa_debian_locate_apt_key() {
    # """
    # 'apt-key' is deprecated and scheduled to be removed in Debian 11.
    # """
    koopa_locate_app '/usr/bin/apt-key'
}

koopa_debian_locate_dpkg() {
    koopa_locate_app '/usr/bin/dpkg'
}

koopa_debian_locate_dpkg_reconfigure() {
    koopa_locate_app '/usr/sbin/dpkg-reconfigure'
}

koopa_debian_locate_gdebi() {
    # """
    # Requires 'gdebi-core' to be installed.
    # """
    koopa_locate_app '/usr/bin/gdebi'
}

koopa_debian_locate_locale_gen() {
    koopa_locate_app '/usr/sbin/locale-gen'
}

koopa_debian_locate_service() {
    koopa_locate_app '/usr/sbin/service'
}

koopa_debian_locate_timedatectl() {
    koopa_locate_app '/usr/bin/timedatectl'
}

koopa_debian_locate_unattended_upgrades() {
    koopa_locate_app '/usr/bin/unattended-upgrades'
}

koopa_debian_locate_update_locale() {
    koopa_locate_app '/usr/sbin/update-locale'
}
