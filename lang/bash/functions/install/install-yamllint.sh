#!/usr/bin/env bash

_koopa_install_yamllint() {
    _koopa_install_app \
        --installer='python-package' \
        --name='yamllint' \
        "$@"
}
