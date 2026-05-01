#!/usr/bin/env bash

_koopa_install_bat() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='bat' \
        "$@"
}
