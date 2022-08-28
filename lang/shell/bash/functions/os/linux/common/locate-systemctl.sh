#!/usr/bin/env bash

koopa_linux_locate_systemctl() {
    local args
    args=()
    case "$(koopa_os_id)" in
        'debian')
            args+=('/bin/systemctl')
            ;;
        *)
            args+=('/usr/bin/systemctl')
            ;;
    esac
    koopa_locate_app "${args[@]}" "$@"
}
