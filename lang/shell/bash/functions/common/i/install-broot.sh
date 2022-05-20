#!/usr/bin/env bash

koopa_install_broot() {
    koopa_install_app \
        --link-in-bin='bin/broot' \
        --name='broot' \
        --installer='rust-package' \
        "$@"
}
