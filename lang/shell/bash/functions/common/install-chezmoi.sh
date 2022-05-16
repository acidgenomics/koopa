#!/usr/bin/env bash

koopa_install_chezmoi() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/chezmoi' \
        --name='chezmoi' \
        "$@"
}

koopa_uninstall_chezmoi() { # {{{3
    koopa_uninstall_app \
        --name='chezmoi' \
        --unlink-in-bin='chezmoi' \
        "$@"
}
