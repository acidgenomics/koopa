#!/usr/bin/env bash

# FIXME Need to prefix all of these with 'linux'.

# FIXME What about systemd on Fedora?

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

# FIXME This is at '/sbin/ldconfig' on Debian.
# FIXME This is at '/usr/sbin/ldconfig' on Fedora.
koopa::locate_ldconfig() { # {{{1
    # """
    # Locate Linux 'ldconfig'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/sbin/ldconfig'
}

koopa::locate_localedef() { # {{{1
    # """
    # Locate Linux 'localedef'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/localedef'
}

# FIXME This is Debian-specific.
koopa::locate_locale_gen() { # {{{1
    # """
    # Locate Linux 'locale-gen'.
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

# FIXME This is /bin/systemctl on Debian.
# FIXME This is /usr/bin/systemctl on Fedora.
koopa::locate_systemctl() { # {{{1
    # """
    # Locate Linux 'systemctl'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/bin/systemctl'
}

# FIXME This is in sbin on Fedora.
koopa::locate_update_alternatives() { # {{{1
    # """
    # Locate Linux 'update-alternatives'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/update-alternatives'
}

# FIXME This is missing on Fedora.
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
