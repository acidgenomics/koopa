#!/usr/bin/env bash

koopa_install_openssh() {
    koopa_install_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        "$@"
}
