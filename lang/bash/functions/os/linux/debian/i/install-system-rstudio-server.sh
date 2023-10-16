#!/usr/bin/env bash

koopa_debian_install_system_rstudio_server() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}
