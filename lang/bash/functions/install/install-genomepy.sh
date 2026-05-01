#!/usr/bin/env bash

_koopa_install_genomepy() {
    _koopa_install_app \
        --installer='conda-package' \
        --name='genomepy' \
        "$@"
}
