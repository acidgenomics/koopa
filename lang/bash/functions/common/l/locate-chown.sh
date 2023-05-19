#!/usr/bin/env bash

koopa_locate_chown() {
    local -a args
    args=()
    if koopa_is_macos
    then
        args+=('/usr/sbin/chown')
    else
        args+=('/bin/chown')
    fi
    koopa_locate_app "${args[@]}" "$@"
}
