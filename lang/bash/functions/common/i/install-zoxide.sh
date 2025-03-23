#!/usr/bin/env bash

koopa_install_zoxide() {
    koopa_install_app \
        --installer='conda-package' \
        --name='zoxide' \
        "$@"
}
