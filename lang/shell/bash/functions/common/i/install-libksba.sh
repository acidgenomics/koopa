#!/usr/bin/env bash

koopa_install_libksba() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='libksba' \
        "$@"
}
