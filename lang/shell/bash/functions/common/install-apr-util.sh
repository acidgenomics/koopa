#!/usr/bin/env bash

koopa_install_apr_util() { # {{{3
    koopa_install_app \
        --name-fancy='Apache Portable Runtime (APR) utilities' \
        --name='apr-util' \
        "$@"
}

koopa_uninstall_apr_util() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Apache Portable Runtime (APR) utilities' \
        --name='apr-util' \
        "$@"
}
