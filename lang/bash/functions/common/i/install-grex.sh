#!/usr/bin/env bash

koopa_install_grex() {
    koopa_install_app \
        --installer='conda-package' \
        --name='grex' \
        "$@"
}
