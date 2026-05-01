#!/usr/bin/env bash

_koopa_install_pycodestyle() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pycodestyle' \
        "$@"
}
