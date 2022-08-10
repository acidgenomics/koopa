#!/usr/bin/env bash

koopa_install_libgpg_error() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='libgpg-error' \
        "$@"
}
