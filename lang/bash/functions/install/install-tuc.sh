#!/usr/bin/env bash

_koopa_install_tuc() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='tuc' \
        "$@"
}
