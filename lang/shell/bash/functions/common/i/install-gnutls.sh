#!/usr/bin/env bash

koopa_install_gnutls() {
    koopa_install_app \
        --activate-opt='gmp' \
        --activate-opt='libtasn1' \
        --activate-opt='libunistring' \
        --activate-opt='nettle' \
        --installer='gnupg-gcrypt' \
        --name='gnutls' \
        -D '--without-p11-kit' \
        "$@"
}
