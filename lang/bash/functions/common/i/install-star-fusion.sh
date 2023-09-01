#!/usr/bin/env bash

koopa_install_star_fusion() {
    koopa_install_app \
        --installer='conda-package' \
        --name='star-fusion' \
        "$@"
}
