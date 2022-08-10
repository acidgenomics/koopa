#!/usr/bin/env bash

koopa_linux_install_pinentry() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='pinentry' \
        "$@"
}
