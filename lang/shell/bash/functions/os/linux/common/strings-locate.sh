#!/usr/bin/env bash

# FIXME Need to prefix all of these with 'linux'.

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
    local os_id str
    os_id="$(koopa::os_id)"
    case "$os_id" in
        'alpine' | \
        'debian')
            str='/sbin/ldconfig'
            ;;
        *)
            str='/usr/sbin/ldconfig'
            ;;
    esac
    koopa:::locate_app "$str"
}

koopa::locate_localedef() { # {{{1
    # """
    # Locate Linux 'localedef'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/bin/localedef'
}

koopa::locate_systemctl() { # {{{1
    # """
    # Locate Linux 'systemctl'.
    # @note Updated 2021-11-02.
    # 
    # Requires systemd to be installed.
    # """
    local os_id str
    os_id="$(koopa::os_id)"
    case "$os_id" in
        'debian')
            str='/bin/systemctl'
            ;;
        *)
            str='/usr/bin/systemctl'
            ;;
    esac
    koopa:::locate_app "$str"
}

koopa::locate_update_alternatives() { # {{{1
    # """
    # Locate Linux 'update-alternatives'.
    # @note Updated 2021-11-02.
    # """
    local str
    if koopa::is_fedora_like
    then
        str='/usr/sbin/update-alternatives'
    else
        str='/usr/bin/update-alternatives'
    fi
    koopa:::locate_app "$str"
}

koopa::locate_usermod() { # {{{1
    # """
    # Locate Linux 'usermod'.
    # @note Updated 2021-11-02.
    # """
    koopa:::locate_app '/usr/sbin/usermod'
}
