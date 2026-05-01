#!/usr/bin/env bash

_koopa_install_ruff() {
    _koopa_install_app \
        --installer='python-package' \
        --name='ruff' \
        "$@"
}
