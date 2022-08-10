#!/usr/bin/env bash

koopa_install_libassuan() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='libassuan' \
        "$@"
}
