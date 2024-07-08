#!/usr/bin/env bash

koopa_install_salmon() {
    koopa_install_app \
        --installer='conda-package' \
        --name='salmon' \
        "$@"
}
