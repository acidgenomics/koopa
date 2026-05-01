#!/usr/bin/env bash

_koopa_install_procs() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='procs' \
        "$@"
}
