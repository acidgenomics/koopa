#!/usr/bin/env bash

_koopa_install_fish() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='fish' \
        "$@"
}
