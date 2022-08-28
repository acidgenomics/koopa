#!/usr/bin/env bash

koopa_linux_locate_ldconfig() {
    local args
    args=()
    case "$(koopa_os_id)" in
        'alpine' | \
        'debian')
            args+=('/sbin/ldconfig')
            ;;
        *)
            args+=('/usr/sbin/ldconfig')
            ;;
    esac
    koopa_locate_app "${args[@]}" "$@"
}
