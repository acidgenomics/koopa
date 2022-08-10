#!/usr/bin/env bash

koopa_install_libgcrypt() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='libgcrypt' \
        "$@"
}
