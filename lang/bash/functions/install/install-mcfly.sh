#!/usr/bin/env bash

_koopa_install_mcfly() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='mcfly' \
        "$@"
}
