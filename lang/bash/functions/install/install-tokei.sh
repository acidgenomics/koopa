#!/usr/bin/env bash

_koopa_install_tokei() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='tokei' \
        "$@"
}
