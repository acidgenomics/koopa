#!/usr/bin/env bash

_koopa_install_hyperfine() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='hyperfine' \
        "$@"
}
