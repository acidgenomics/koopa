#!/usr/bin/env bash

_koopa_locate_chown() {
    local -a args
    args=()
    if _koopa_is_macos
    then
        args+=('/usr/sbin/chown')
    else
        args+=('/bin/chown')
    fi
    _koopa_locate_app "${args[@]}" "$@"
}
