#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --name='du-dust' \
        --installer='rust-package' \
        "$@"
}
