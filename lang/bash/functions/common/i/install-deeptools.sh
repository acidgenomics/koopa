#!/usr/bin/env bash

koopa_install_deeptools() {
    koopa_install_app \
        --installer='python-package' \
        --name='deeptools' \
        "$@"
}
