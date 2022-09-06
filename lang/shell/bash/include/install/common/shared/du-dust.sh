#!/usr/bin/env bash

main() {
    koopa_install_app_passthrough \
        --name='du-dust' \
        --installer='rust-package' \
        "$@"
}
