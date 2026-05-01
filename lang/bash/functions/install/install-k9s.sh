#!/usr/bin/env bash

_koopa_install_k9s() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='k9s' \
        "$@"
}
