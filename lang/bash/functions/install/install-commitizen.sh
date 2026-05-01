#!/usr/bin/env bash

_koopa_install_commitizen() {
    _koopa_install_app \
        --installer='python-package' \
        --name='commitizen' \
        "$@"
}
