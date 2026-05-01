#!/usr/bin/env bash

_koopa_install_zellij() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='zellij' \
        "$@"
}
