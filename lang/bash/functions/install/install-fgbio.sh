#!/usr/bin/env bash

_koopa_install_fgbio() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='fgbio' \
        "$@"
}
