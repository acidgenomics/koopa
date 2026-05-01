#!/usr/bin/env bash

_koopa_install_nushell() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='nushell' \
        "$@"
}
