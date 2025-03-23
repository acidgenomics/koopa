#!/usr/bin/env bash

koopa_install_ripgrep_all() {
    koopa_install_app \
        --installer='conda-package' \
        --name='ripgrep-all' \
        "$@"
}
