#!/usr/bin/env bash

_koopa_install_ripgrep() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='ripgrep' \
        "$@"
}
