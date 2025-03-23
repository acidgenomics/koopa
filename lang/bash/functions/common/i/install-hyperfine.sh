#!/usr/bin/env bash

koopa_install_hyperfine() {
    koopa_install_app \
        --installer='conda-package' \
        --name='hyperfine' \
        "$@"
}
