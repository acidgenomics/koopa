#!/usr/bin/env bash

_koopa_install_starship() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='starship' \
        "$@"
}
