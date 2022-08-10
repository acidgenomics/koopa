#!/usr/bin/env bash

koopa_install_gnutls() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='gnutls' \
        "$@"
}
