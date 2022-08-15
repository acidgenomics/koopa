#!/usr/bin/env bash

main() {
    koopa_install_app \
        --name='delta' \
        --installer='rust-package' \
        "$@"
}
