#!/usr/bin/env bash

koopa_install_bzip2() { # {{{3
    koopa_install_app \
        --name='bzip2' \
        "$@"
}

koopa_uninstall_bzip2() { # {{{3
    koopa_uninstall_app \
        --name='bzip2' \
        "$@"
}
