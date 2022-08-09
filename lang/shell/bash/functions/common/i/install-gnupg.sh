#!/usr/bin/env bash

koopa_install_gnupg() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='gnupg' \
        "$@"
}
