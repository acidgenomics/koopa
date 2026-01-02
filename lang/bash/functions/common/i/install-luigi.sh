#!/usr/bin/env bash

koopa_install_luigi() {
    koopa_install_app \
        --installer='conda-package' \
        --name='luigi' \
        "$@"
}
