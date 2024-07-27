#!/usr/bin/env bash

# FIXME This is now failing to build with Rust 1.80.

koopa_install_eza() {
    koopa_install_app \
        --installer='rust-package' \
        --name='eza' \
        "$@"
}
