#!/usr/bin/env bash

_koopa_install_poetry() {
    _koopa_install_app \
        --installer='python-package' \
        --name='poetry' \
        "$@"
}
