#!/usr/bin/env bash

koopa_linux_install_pinentry() {
    koopa_install_app \
        --activate-opt='libgpg-error' \
        --activate-opt='libassuan' \
        --installer='gnupg-gcrypt' \
        --name='pinentry' \
        "$@"
}
