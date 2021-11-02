#!/usr/bin/env bash

# FIXME Need to ensure that all of these are current in called functions.

koopa::debian_locate_apt() { # {{{1
    # """
    # Locate Debian 'apt'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/apt'
}

koopa::debian_locate_apt_get() { # {{{1
    # """
    # Locate Debian 'apt-get'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/apt-get'
}

# NOTE Debian 'apt-key' is deprecated and will be removed in 11 release.
# > koopa::debian_locate_apt_key() { # {{{1
# >     # """
# >     # Locate Debian 'apt-key'.
# >     # @note Updated 2021-11-02.
# >     # """
# >     koopa:::locate_app '/usr/bin/apt-key'
# > }

koopa::debian_locate_dpkg() { # {{{1
    # """
    # Locate Debian 'dpkg'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/dpkg'
}

koopa::debian_locate_dpkg_reconfigure() { # {{{1
    # """
    # Locate Debian 'dpkg-reconfigure'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/dpkg-reconfigure'
}

koopa::debian_locate_gdebi() { # {{{1
    # """
    # Locate Debian 'gdebi'.
    # @note Updated 2021-11-02.
    #
    # Requires 'gdebi-core' to be installed.
    # """
    koopa:::locate_app '/usr/bin/gdebi'
}

koopa::debian_locate_locale_gen() { # {{{1
    # """
    # Locate Debian 'locale-gen'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/locale-gen'
}

koopa::debian_locate_service() { # {{{1
    # """
    # Locate Debian 'service'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/service'
}

koopa::debian_locate_unattended_upgrades() { # {{{1
    # """
    # Locate Debian 'unattended-upgrades'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/unattended-upgrades'
}

koopa::debian_locate_update_locale() { # {{{1
    # """
    # Locate Debian 'update-locale'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/update-locale'
}
