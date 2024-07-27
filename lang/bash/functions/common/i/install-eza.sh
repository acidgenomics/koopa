#!/usr/bin/env bash

koopa_install_eza() {
    koopa_install_app \
        --installer='rust-package' \
        --name='eza' \
        "$@"
}
