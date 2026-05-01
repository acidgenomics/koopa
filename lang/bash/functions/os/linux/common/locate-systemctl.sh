#!/usr/bin/env bash

_koopa_linux_locate_systemctl() {
    local args
    args=()
    case "$(_koopa_os_id)" in
        'debian')
            args+=('/bin/systemctl')
            ;;
        *)
            args+=('/usr/bin/systemctl')
            ;;
    esac
    _koopa_locate_app "${args[@]}" "$@"
}
