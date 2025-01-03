#!/usr/bin/env bash

koopa_debian_install_system_shiny_server() {
    koopa_assert_is_not_arm64
    koopa_install_app \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}
