#!/usr/bin/env bash

koopa_install_scalene() {
    koopa_install_app \
        --installer='python-package' \
        --name='scalene' \
        "$@"
}
