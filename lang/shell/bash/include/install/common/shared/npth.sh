#!/usr/bin/env bash

koopa_install_npth() {
    koopa_install_app_internal \
        --installer='gnupg-gcrypt' \
        --name='npth' \
        "$@"
}
