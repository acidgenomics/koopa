#!/usr/bin/env bash

koopa_install_nushell() {
    koopa_install_app \
        --installer='rust-package' \
        --name='nushell' \
        "$@"
}
