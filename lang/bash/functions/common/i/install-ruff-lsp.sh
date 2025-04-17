#!/usr/bin/env bash

koopa_install_ruff_lsp() {
    koopa_install_app \
        --installer='python-package' \
        --name='ruff-lsp' \
        "$@"
}
