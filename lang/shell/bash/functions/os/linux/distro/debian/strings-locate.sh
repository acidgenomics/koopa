#!/usr/bin/env bash

# - apt
# - apt-get  # debian
# - dpkg  # debian
# - dpkg-reconfigure  # debian
# - gdebi  # debian

koopa::debian_locate_dpkg() { # {{{1
    # """
    # Locate Debian 'dpkg'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/dpkg'
}

koopa::debian_locate_unattended_upgrades() { # {{{1
    # """
    # Locate Debian 'unattended-upgrades'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/unattended-upgrades'
}

koopa::debian_locate_service() { # {{{1
    # """
    # Locate Debian 'service'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/service'
}
