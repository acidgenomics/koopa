#!/usr/bin/env bash

koopa_install_ruff() {
    koopa_install_app \
        --installer='python-package' \
        --name='ruff' \
        "$@"
}
