#!/usr/bin/env bash

_koopa_install_mypy() {
    _koopa_install_app \
        --installer='python-package' \
        --name='mypy' \
        "$@"
}
