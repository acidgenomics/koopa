#!/usr/bin/env bash

# FIXME Ensure we unlink in koopa bin.

koopa_debian_uninstall_shiny_server() {
    koopa_uninstall_app \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}
