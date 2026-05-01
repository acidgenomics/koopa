#!/usr/bin/env bash

_koopa_linux_install_aspera_connect() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}
