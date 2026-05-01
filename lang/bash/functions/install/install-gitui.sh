#!/usr/bin/env bash

_koopa_install_gitui() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='gitui' \
        "$@"
}
