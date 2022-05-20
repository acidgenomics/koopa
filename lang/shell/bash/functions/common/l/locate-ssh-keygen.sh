#!/usr/bin/env bash

koopa_locate_ssh_keygen() {
    koopa_locate_app \
        --app-name='ssh-keygen' \
        --opt-name='openssh'
}
