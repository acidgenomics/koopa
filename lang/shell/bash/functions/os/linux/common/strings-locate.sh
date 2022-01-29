#!/usr/bin/env bash

koopa::linux_locate_bcbio() { # {{{1
    koopa::locate_app 'bcbio-nextgen.py'
}

koopa::linux_locate_bcl2fastq() { # {{{1
    koopa::locate_app 'bcl2fastq'
}

koopa::linux_locate_getconf() { # {{{1
    koopa::locate_app '/usr/bin/getconf'
}

koopa::linux_locate_groupadd() { # {{{1
    koopa::locate_app '/usr/sbin/groupadd'
}

koopa::linux_locate_gpasswd() { # {{{1
    koopa::locate_app '/usr/bin/gpasswd'
}

koopa::linux_locate_ldconfig() { # {{{1
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
    koopa::locate_app '/usr/sbin/useradd'
}

koopa::linux_locate_usermod() { # {{{1
    koopa::locate_app '/usr/sbin/usermod'
}
