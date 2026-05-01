#!/usr/bin/env bash

_koopa_install_flake8() {
    _koopa_install_app \
        --installer='python-package' \
        --name='flake8' \
        "$@"
}
