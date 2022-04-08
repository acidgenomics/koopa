#!/usr/bin/env bash

koopa_linux_locate_bcbio() { # {{{1
    koopa_locate_app 'bcbio-nextgen.py'
}

koopa_linux_locate_bcl2fastq() { # {{{1
    koopa_locate_app 'bcl2fastq'
}

koopa_linux_locate_getconf() { # {{{1
    koopa_locate_app '/usr/bin/getconf'
}

koopa_linux_locate_groupadd() { # {{{1
    koopa_locate_app '/usr/sbin/groupadd'
}

koopa_linux_locate_gpasswd() { # {{{1
    koopa_locate_app '/usr/bin/gpasswd'
}

koopa_linux_locate_ldconfig() { # {{{1
    local os_id str
    os_id="$(koopa_os_id)"
    case "$os_id" in
        'alpine' | \
        'debian')
            str='/sbin/ldconfig'
            ;;
        *)
            str='/usr/sbin/ldconfig'
            ;;
    esac
    koopa_locate_app "$str"
}

koopa_linux_locate_systemctl() { # {{{1
    local os_id str
    os_id="$(koopa_os_id)"
    case "$os_id" in
        'debian')
            str='/bin/systemctl'
            ;;
        *)
            str='/usr/bin/systemctl'
            ;;
    esac
    koopa_locate_app "$str"
}

koopa_linux_locate_update_alternatives() { # {{{1
    local str
    if koopa_is_fedora_like
    then
        str='/usr/sbin/update-alternatives'
    else
        str='/usr/bin/update-alternatives'
    fi
    koopa_locate_app "$str"
}

koopa_linux_locate_useradd() { # {{{1
    koopa_locate_app '/usr/sbin/useradd'
}

koopa_linux_locate_usermod() { # {{{1
    koopa_locate_app '/usr/sbin/usermod'
}
