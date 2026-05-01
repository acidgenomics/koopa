#!/usr/bin/env bash

_koopa_install_pyflakes() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pyflakes' \
        "$@"
}
