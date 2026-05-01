#!/usr/bin/env bash

_koopa_install_zoxide() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='zoxide' \
        "$@"
}
