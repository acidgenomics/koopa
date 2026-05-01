#!/usr/bin/env bash

_koopa_install_py_spy() {
    _koopa_install_app \
        --installer='python-package' \
        --name='py-spy' \
        "$@"
}
