#!/usr/bin/env bash

koopa_install_bpytop() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/bpytop' \
        --name='bpytop' \
        "$@"
}

koopa_uninstall_bpytop() { # {{{3
    koopa_uninstall_app \
        --name='bpytop' \
        --unlink-in-bin='bpytop' \
        "$@"
}
