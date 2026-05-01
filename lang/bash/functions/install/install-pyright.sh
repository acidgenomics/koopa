#!/usr/bin/env bash

_koopa_install_pyright() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pyright' \
        "$@"
}
