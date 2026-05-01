#!/usr/bin/env bash

_koopa_install_zenith() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='zenith' \
        "$@"
}
