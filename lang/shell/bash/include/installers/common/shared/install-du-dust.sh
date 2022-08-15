#!/usr/bin/env bash

main() {
    koopa_install_app \
        --name='du-dust' \
        --installer='rust-package' \
        "$@"
}
