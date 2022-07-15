#!/usr/bin/env bash

koopa_fedora_install_system_shiny_server() {
    koopa_install_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}
