#!/usr/bin/env bash

# FIXME Need to prefix all of these with 'linux'.

# FIXME Need to add these, some of which are distro-specific.
# - rpm  # fedora
# - zypper  # opensuse

koopa::locate_groupadd() { # {{{1
    # """
    # Locate Linux 'groupadd'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/groupadd'
}

koopa::locate_gpasswd() { # {{{1
    # """
    # Locate Linux 'gpasswd'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/gpasswd'
}

koopa::locate_ldconfig() { # {{{1
    # """
    # Locate Linux 'ldconfig'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/sbin/ldconfig'
}

# FIXME Is this on Fedora?
koopa::locate_localedef() { # {{{1
    # """
    # Locate Linux 'localedef'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/localedef'
}

koopa::locate_locale_gen() { # {{{1
    # """
    # Locate Linux 'locale-gen'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/locale-gen'
}

koopa::locate_service() { # {{{1
    # """
    # Locate Linux 'service'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/service'
}

koopa::locate_systemctl() { # {{{1
    # """
    # Locate Linux 'systemctl'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/bin/systemctl'
}

koopa::locate_update_alternatives() { # {{{1
    # """
    # Locate Linux 'update-alternatives'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/update-alternatives'
}

# FIXME Is this on Fedora?
koopa::locate_update_locale() { # {{{1
    # """
    # Locate Linux 'update-locale'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/update-locale'
}

koopa::locate_usermod() { # {{{1
    # """
    # Locate Linux 'usermod'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/usermod'
}
