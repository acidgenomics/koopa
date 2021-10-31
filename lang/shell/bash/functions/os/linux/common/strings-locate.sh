#!/usr/bin/env bash

# FIXME Need to prefix all of these with 'linux'.

# FIXME Need to add these, some of which are distro-specific.
# - apk  # alpine
# - apt  # debian
# - apt-get  # debian
# - dpkg  # debian
# - dpkg-reconfigure  # debian
# - gdebi  # debian
# - gpasswd
# - groupadd
# - ldconfig
# - localedef  # fedora?
# - locale-gen
# - rpm  # fedora
# - service  # fedora? is this on debian too?
# - unattended-upgrades
# - update-locale
# - usermod
# - zypper  # opensuse

koopa::locate_ldconfig() { # {{{1
    # """
    # Locate Linux ldconfig.
    # @note Updated 2021-10-31.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app '/sbin/ldconfig'
}

koopa::locate_systemctl() { # {{{1
    # """
    # Locate Linux systemctl.
    # @note Updated 2021-10-31.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'systemctl'  # FIXME Harden this
}

koopa::locate_update_alternatives() { # {{{1
    # """
    # Locate Linux update-alternatives.
    # @note Updated 2021-10-31.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'update-alternatives'  # FIXME Harden this
}
