#!/usr/bin/env bash

koopa_locate_ssh_add() {
    if koopa_is_macos
    then
        koopa_locate_app '/usr/bin/ssh-add'
    else
        koopa_locate_app \
            --app-name='ssh-add' \
            --opt-name='openssh'
    fi
}
