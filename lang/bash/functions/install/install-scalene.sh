#!/usr/bin/env bash

_koopa_install_scalene() {
    _koopa_install_app \
        --installer='python-package' \
        --name='scalene' \
        "$@"
}
