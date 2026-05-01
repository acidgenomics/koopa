#!/usr/bin/env bash

_koopa_fedora_install_system_shiny_server() {
    _koopa_install_app \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}
