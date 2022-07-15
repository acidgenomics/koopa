#!/usr/bin/env bash

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
