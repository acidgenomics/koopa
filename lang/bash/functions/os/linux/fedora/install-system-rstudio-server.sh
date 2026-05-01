#!/usr/bin/env bash

_koopa_fedora_install_system_rstudio_server() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}
