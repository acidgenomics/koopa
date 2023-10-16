#!/usr/bin/env bash

koopa_linux_install_aspera_connect() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}
