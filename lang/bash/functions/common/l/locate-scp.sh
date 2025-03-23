#!/usr/bin/env bash

koopa_locate_scp() {
    local -a args
    if koopa_is_macos
    then
        args+=('/usr/bin/scp')
    else
        args+=(
            '--app-name=openssh'
            '--bin-name=scp'
        )
    fi
    koopa_locate_app "${args[@]}" "$@"
}
