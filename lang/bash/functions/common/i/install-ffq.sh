#!/usr/bin/env bash

koopa_install_ffq() {
    koopa_install_app \
        --installer='conda-package' \
        --name='ffq' \
        "$@"
}
