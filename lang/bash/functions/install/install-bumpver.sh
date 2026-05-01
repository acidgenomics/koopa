#!/usr/bin/env bash

_koopa_install_bumpver() {
    _koopa_install_app \
        --installer='python-package' \
        --name='bumpver' \
        "$@"
}
