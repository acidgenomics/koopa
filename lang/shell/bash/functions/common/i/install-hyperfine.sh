#!/usr/bin/env bash

koopa_install_hyperfine() {
    koopa_install_app \
        --link-in-bin='bin/hyperfine' \
        --name='hyperfine' \
        --installer='rust-package' \
        "$@"
}
