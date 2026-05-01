#!/usr/bin/env bash

_koopa_install_rmate() {
    _koopa_install_app \
        --installer='ruby-package' \
        --name='rmate' \
        "$@"
}
