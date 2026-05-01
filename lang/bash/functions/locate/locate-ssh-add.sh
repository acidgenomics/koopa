#!/usr/bin/env bash

_koopa_locate_ssh_add() {
    _koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh-add' \
        "$@"
}
