#!/usr/bin/env bash

_koopa_install_ruff_lsp() {
    _koopa_install_app \
        --installer='python-package' \
        --name='ruff-lsp' \
        "$@"
}
