#!/usr/bin/env bash

_koopa_install_sd() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='sd' \
        "$@"
}
