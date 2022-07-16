#!/usr/bin/env bash

koopa_fedora_uninstall_system_shiny_server() {
    koopa_uninstall_app \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}
