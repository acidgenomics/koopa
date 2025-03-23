#!/usr/bin/env bash

koopa_install_chezmoi() {
    koopa_install_app \
        --installer='conda-package' \
        --name='chezmoi' \
        "$@"
}
