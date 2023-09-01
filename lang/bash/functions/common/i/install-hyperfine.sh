#!/usr/bin/env bash

koopa_install_hyperfine() {
    koopa_install_app \
        --installer='rust-package' \
        --name='hyperfine' \
        "$@"
}
