#!/usr/bin/env bash

_koopa_install_bpytop() {
    _koopa_install_app \
        --installer='python-package' \
        --name='bpytop' \
        "$@"
}
