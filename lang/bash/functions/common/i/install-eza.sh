#!/usr/bin/env bash

koopa_install_eza() {
    koopa_install_app \
        --installer='conda-package' \
        --name='eza' \
        "$@"
}
