#!/usr/bin/env bash

koopa_install_genomepy() {
    koopa_install_app \
        --installer='conda-package' \
        --name='genomepy' \
        "$@"
}
