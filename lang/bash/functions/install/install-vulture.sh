#!/usr/bin/env bash

_koopa_install_vulture() {
    _koopa_install_app \
        --installer='python-package' \
        --name='vulture' \
        "$@"
}
