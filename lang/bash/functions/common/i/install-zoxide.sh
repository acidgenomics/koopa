#!/usr/bin/env bash

koopa_install_zoxide() {
    koopa_install_app \
        --installer='rust-package' \
        --name='zoxide' \
        "$@"
}
