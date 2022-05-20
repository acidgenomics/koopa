#!/usr/bin/env bash

koopa_install_apr_util() {
    koopa_install_app \
        --name-fancy='Apache Portable Runtime (APR) utilities' \
        --name='apr-util' \
        "$@"
}
