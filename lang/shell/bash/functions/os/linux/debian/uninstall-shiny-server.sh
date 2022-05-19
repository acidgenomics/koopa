#!/usr/bin/env bash

koopa_debian_uninstall_shiny_server() {
    koopa_uninstall_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}
