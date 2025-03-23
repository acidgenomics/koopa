#!/usr/bin/env bash

koopa_install_rmate() {
    koopa_install_app \
        --installer='ruby-package' \
        --name='rmate' \
        "$@"
}
