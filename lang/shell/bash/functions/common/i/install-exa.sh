#!/usr/bin/env bash

# NOTE 0.10.0 currently fails to build with Rust 1.61.0.
# https://github.com/ogham/exa/issues/1068

koopa_install_exa() {
    koopa_install_app \
        --link-in-bin='bin/exa' \
        --name='exa' \
        --installer='rust-package' \
        "$@"
}
