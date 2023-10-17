#!/usr/bin/env bash

koopa_install_star() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --installer='star-conda' \
        --name='star' \
        "$@"
}
