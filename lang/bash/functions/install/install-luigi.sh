#!/usr/bin/env bash

_koopa_install_luigi() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='luigi' \
        "$@"
}
