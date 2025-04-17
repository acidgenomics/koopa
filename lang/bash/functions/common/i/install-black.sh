#!/usr/bin/env bash

koopa_install_black() {
    koopa_install_app \
        --installer='python-package' \
        --name='black' \
        -D --pip-name='black[d]' \
        "$@"
}
