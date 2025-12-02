#!/usr/bin/env bash

koopa_install_fzf() {
    koopa_install_app \
        --installer='conda-package' \
        --name='fzf' \
        "$@"
}
