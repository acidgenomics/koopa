#!/usr/bin/env bash

koopa_install_httpx() {
    koopa_install_app \
        --installer='python-package' \
        --name='httpx' \
        -D --pip-name='httpx[cli]' \
        "$@"
}
