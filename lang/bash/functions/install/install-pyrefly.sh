#!/usr/bin/env bash

_koopa_install_pyrefly() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pyrefly' \
        "$@"
}
