#!/usr/bin/env bash

koopa_install_conda() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/conda' \
        --name-fancy='Miniconda' \
        --name='conda' \
        "$@"
}

koopa_uninstall_conda() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Miniconda' \
        --name='conda' \
        --unlink-in-bin='conda' \
        "$@"
}
