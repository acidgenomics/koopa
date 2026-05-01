#!/usr/bin/env bash

_koopa_locate_scp() {
    local -a args
    if _koopa_is_macos
    then
        args+=('/usr/bin/scp')
    else
        args+=(
            '--app-name=openssh'
            '--bin-name=scp'
        )
    fi
    _koopa_locate_app "${args[@]}" "$@"
}
