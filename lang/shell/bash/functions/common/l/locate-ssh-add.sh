#!/usr/bin/env bash

koopa_locate_ssh_add() {
    local args
    args=()
    if koopa_is_macos
    then
        args+=('/usr/bin/ssh-add')
    else
        args+=(
            '--app-name=openssh'
            '--bin-name=ssh-add'
        )
    fi
    koopa_locate_app "${args[@]}" "$@"
}
