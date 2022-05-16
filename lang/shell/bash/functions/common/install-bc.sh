#!/usr/bin/env bash

koopa_install_bc() { # {{{3
    koopa_install_app \
        --installer='gnu-app' \
        --link-in-bin='bin/bc' \
        --name='bc' \
        "$@"
}

koopa_uninstall_autoconf() { # {{{3
    koopa_uninstall_app \
        --name='bc' \
        --unlink-in-bin='bc' \
        "$@"
}
