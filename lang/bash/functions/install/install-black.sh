#!/usr/bin/env bash

_koopa_install_black() {
    _koopa_install_app \
        --installer='python-package' \
        --name='black' \
        -D --pip-name='black[d]' \
        "$@"
}
