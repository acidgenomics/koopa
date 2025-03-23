#!/usr/bin/env bash

koopa_install_hexyl() {
    koopa_install_app \
        --installer='rust-package' \
        --name='hexyl' \
        "$@"
}
