#!/usr/bin/env bash

koopa_uninstall_apr_util() {
    koopa_uninstall_app \
        --name-fancy='Apache Portable Runtime (APR) utilities' \
        --name='apr-util' \
        "$@"
}
