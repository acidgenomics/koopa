#!/usr/bin/env bash

main() {
    koopa_install_app_subshell \
        --installer='python-package' \
        --name='ruff-lsp' \
        -D --package-name='ruff_lsp'
}
