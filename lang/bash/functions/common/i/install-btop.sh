#!/usr/bin/env bash

koopa_install_btop() {
    koopa_install_app \
        --installer='conda-package' \
        --name='btop' \
        "$@"
}
