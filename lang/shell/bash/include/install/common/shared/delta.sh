#!/usr/bin/env bash

main() {
    koopa_install_app_internal \
        --name='delta' \
        --installer='rust-package' \
        "$@"
}
