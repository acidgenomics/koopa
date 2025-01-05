#!/usr/bin/env bash

koopa_install_ripgrep() {
    koopa_install_app \
        --installer='conda-package' \
        --name='ripgrep' \
        "$@"
}
