#!/usr/bin/env bash

koopa_install_star_fusion() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='conda-package' \
        --name='star-fusion' \
        "$@"
}
