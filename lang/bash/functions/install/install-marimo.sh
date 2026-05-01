#!/usr/bin/env bash

_koopa_install_marimo() {
    _koopa_install_app \
        --installer='python-package' \
        --name='marimo' \
        "$@"
}
