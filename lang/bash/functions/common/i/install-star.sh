#!/usr/bin/env bash

koopa_install_star() {
    if koopa_is_aarch64
    then
        koopa_install_app \
            --installer='star-src' \
            --name='star' \
            "$@"
    else
        koopa_install_app \
            --installer='star-conda' \
            --name='star' \
            "$@"
    fi
}
