#!/usr/bin/env bash

_koopa_install_bottom() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='bottom' \
        "$@"
}
