#!/usr/bin/env bash

_koopa_debian_uninstall_shiny_server() {
    _koopa_uninstall_app \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}
