#!/usr/bin/env bash

_koopa_install_tqdm() {
    _koopa_install_app \
        --installer='python-package' \
        --name='tqdm' \
        "$@"
}
