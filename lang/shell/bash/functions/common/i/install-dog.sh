#!/usr/bin/env bash

# NOTE Currently has build issues on Ubuntu 20 with Rust 1.61.

koopa_install_dog() {
    koopa_install_app \
        --link-in-bin='bin/dog' \
        --name='dog' \
        --installer='rust-package' \
        "$@"
}
