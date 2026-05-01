#!/usr/bin/env bash

_koopa_install_btop() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='btop' \
        "$@"
}
