#!/usr/bin/env bash

koopa_install_black() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/black' \
        --name='black' \
        "$@"
}

koopa_uninstall_black() { # {{{3
    koopa_uninstall_app \
        --name='black' \
        --unlink-in-bin='black' \
        "$@"
}
