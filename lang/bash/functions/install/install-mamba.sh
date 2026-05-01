#!/usr/bin/env bash

_koopa_install_mamba() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='mamba' \
        "$@"
}
