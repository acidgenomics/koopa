#!/usr/bin/env bash

_koopa_install_mdcat() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='mdcat' \
        "$@"
}
