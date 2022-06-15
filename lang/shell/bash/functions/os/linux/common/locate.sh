#!/usr/bin/env bash

koopa_linux_locate_bcbio() {
    koopa_locate_app 'bcbio-nextgen.py'
}

koopa_linux_locate_bcl2fastq() {
    koopa_locate_app 'bcl2fastq'
}

koopa_linux_locate_getconf() {
    koopa_locate_app '/usr/bin/getconf'
}

koopa_linux_locate_groupadd() {
    koopa_locate_app '/usr/sbin/groupadd'
}

koopa_linux_locate_gpasswd() {
    koopa_locate_app '/usr/bin/gpasswd'
}

koopa_linux_locate_ldconfig() {
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

koopa_linux_locate_rstudio_server() {
    koopa_locate_app '/usr/sbin/rstudio-server'
}

koopa_linux_locate_shiny_server() {
    koopa_locate_app '/usr/bin/shiny-server'
}

koopa_linux_locate_systemctl() {
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

koopa_linux_locate_update_alternatives() {
    local str
    if koopa_is_fedora_like
    then
        str='/usr/sbin/update-alternatives'
    else
        str='/usr/bin/update-alternatives'
    fi
    koopa_locate_app "$str"
}

koopa_linux_locate_useradd() {
    koopa_locate_app '/usr/sbin/useradd'
}

koopa_linux_locate_usermod() {
    koopa_locate_app '/usr/sbin/usermod'
}
