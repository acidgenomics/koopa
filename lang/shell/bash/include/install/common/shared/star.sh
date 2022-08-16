#!/usr/bin/env bash

main() {
    koopa_install_app \
        --installer='conda-env' \
        --name='star' \
        "$@"
}
