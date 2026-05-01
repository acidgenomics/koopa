#!/usr/bin/env bash

_koopa_install_broot() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='broot' \
        "$@"
}
