#!/usr/bin/env bash

_koopa_install_pipx() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pipx' \
        "$@"
}
