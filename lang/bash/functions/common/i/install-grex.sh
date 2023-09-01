#!/usr/bin/env bash

koopa_install_grex() {
    koopa_install_app \
        --installer='rust-package' \
        --name='grex' \
        "$@"
}
