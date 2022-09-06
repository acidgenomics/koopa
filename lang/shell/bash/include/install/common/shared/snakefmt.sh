#!/usr/bin/env bash

main() {
    koopa_install_app_passthrough \
        --installer='conda-env' \
        --name='snakefmt' \
        "$@"
}
