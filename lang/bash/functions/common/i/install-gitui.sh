#!/usr/bin/env bash

koopa_install_gitui() {
    koopa_install_app \
        --installer='conda-package' \
        --name='gitui' \
        "$@"
}
