#!/usr/bin/env bash

koopa_install_broot() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/broot' \
        --name='broot' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_broot() { # {{{3
    koopa_uninstall_app \
        --name='broot' \
        --unlink-in-bin='broot' \
        "$@"
}
