#!/usr/bin/env bash

koopa_linux_locate_update_alternatives() {
    local args
    args=()
    if koopa_is_fedora_like
    then
        args+=('/usr/sbin/update-alternatives')
    else
        str+=('/usr/bin/update-alternatives')
    fi
    koopa_locate_app "${args[@]}" "$@"
}
