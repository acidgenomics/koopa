#!/usr/bin/env bash

_koopa_install_httpx() {
    _koopa_install_app \
        --installer='python-package' \
        --name='httpx' \
        -D --pip-name='httpx[cli]' \
        "$@"
}
