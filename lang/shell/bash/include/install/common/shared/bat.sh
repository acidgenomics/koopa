#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --name='bat' \
        --installer='rust-package' \
        "$@"
}
