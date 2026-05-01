#!/usr/bin/env bash

_koopa_install_pygments() {
    _koopa_install_app \
        --installer='python-package' \
        --name='pygments' \
        "$@"
}
