#!/usr/bin/env bash

koopa_locate_ssh_keygen() {
    koopa_locate_app \
        --app-name='openssh' \
        --bin-name='ssh-keygen'
}
