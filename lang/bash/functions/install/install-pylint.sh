#!/usr/bin/env bash

_koopa_install_pylint() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pylint' \
        "$@"
}
