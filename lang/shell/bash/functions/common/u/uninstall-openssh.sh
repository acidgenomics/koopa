#!/usr/bin/env bash

koopa_uninstall_openssh() {
    koopa_uninstall_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        "$@"
}
