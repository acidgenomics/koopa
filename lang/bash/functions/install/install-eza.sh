#!/usr/bin/env bash

_koopa_install_eza() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='eza' \
        "$@"
}
