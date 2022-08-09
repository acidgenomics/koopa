#!/usr/bin/env bash

koopa_install_npth() {
    koopa_install_app \
        --installer='gnupg-gcrypt' \
        --name='npth' \
        "$@"
}
