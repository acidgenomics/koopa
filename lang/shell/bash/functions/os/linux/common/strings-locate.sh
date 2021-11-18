#!/usr/bin/env bash

koopa::linux_locate_bcl2fastq() { # {{{1
    # """
    # Locate Linux 'bcl2fastq'.
    # @note Updated 2021-11-16.
    # """
    koopa::locate_app 'bcl2fastq'
}

koopa::linux_locate_groupadd() { # {{{1
    # """
    # Locate Linux 'groupadd'.
    # @note Updated 2021-11-02.
    # """
    koopa::locate_app '/usr/sbin/groupadd'
}

koopa::linux_locate_gpasswd() { # {{{1
    # """
    # Locate Linux 'gpasswd'.
    # @note Updated 2021-11-02.
    # """
    koopa::locate_app '/usr/bin/gpasswd'
}

koopa::linux_locate_ldconfig() { # {{{1
    # """
    # Locate Linux 'ldconfig'.
    # @note Updated 2021-11-16.
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
    koopa::locate_app "$str"
}

koopa::linux_locate_systemctl() { # {{{1
    # """
    # Locate Linux 'systemctl'.
    # @note Updated 2021-11-16.
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
    koopa::locate_app "$str"
}

koopa::linux_locate_update_alternatives() { # {{{1
    # """
    # Locate Linux 'update-alternatives'.
    # @note Updated 2021-11-16.
    # """
    local str
    if koopa::is_fedora_like
    then
        str='/usr/sbin/update-alternatives'
    else
        str='/usr/bin/update-alternatives'
    fi
    koopa::locate_app "$str"
}

koopa::linux_locate_useradd() { # {{{1
    # """
    # Locate Linux 'usermod'.
    # @note Updated 2021-11-16.
    # """
    koopa::locate_app '/usr/sbin/useradd'
}

koopa::linux_locate_usermod() { # {{{1
    # """
    # Locate Linux 'usermod'.
    # @note Updated 2021-11-16.
    # """
    koopa::locate_app '/usr/sbin/usermod'
}
