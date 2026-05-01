#!/usr/bin/env bash

_koopa_install_grex() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='grex' \
        "$@"
}
