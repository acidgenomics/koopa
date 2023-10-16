#!/usr/bin/env bash

koopa_install_autodock_adfr() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='autodock-adfr' \
        "$@"
}
