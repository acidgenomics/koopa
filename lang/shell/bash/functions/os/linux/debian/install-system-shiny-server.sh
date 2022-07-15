#!/usr/bin/env bash

# FIXME Consider linking this into '/opt/koopa/bin'.

koopa_debian_install_system_shiny_server() {
    koopa_install_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}
