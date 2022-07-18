#!/usr/bin/env bash

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
