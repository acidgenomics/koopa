#!/usr/bin/env bash

_koopa_debian_install_system_shiny_server() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}
