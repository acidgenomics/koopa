#!/usr/bin/env bash

koopa_install_k9s() {
    koopa_install_app \
        --installer='conda-package' \
        --name='k9s' \
        "$@"
}
