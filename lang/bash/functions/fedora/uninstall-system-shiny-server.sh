#!/usr/bin/env bash

_koopa_fedora_uninstall_system_shiny_server() {
    _koopa_uninstall_app \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}
