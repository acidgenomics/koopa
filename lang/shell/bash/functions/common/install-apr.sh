#!/usr/bin/env bash

koopa_install_apr() { # {{{3
    koopa_install_app \
        --activate-opt='sqlite' \
        --name-fancy='Apache Portable Runtime (APR) library' \
        --name='apr' \
        "$@"
}

koopa_uninstall_apr() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Apache Portable Runtime (APR) library' \
        --name='apr' \
        "$@"
}
