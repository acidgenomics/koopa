#!/usr/bin/env bash

_koopa_install_direnv() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='direnv' \
        "$@"
}
