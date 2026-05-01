#!/usr/bin/env bash

_koopa_linux_locate_ldconfig() {
    local args
    args=()
    case "$(_koopa_os_id)" in
        'alpine' | \
        'debian')
            args+=('/sbin/ldconfig')
            ;;
        *)
            args+=('/usr/sbin/ldconfig')
            ;;
    esac
    _koopa_locate_app "${args[@]}" "$@"
}
