#!/usr/bin/env bash

koopa_install_chemacs() { # {{{3
    koopa_install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}

koopa_uninstall_chemacs() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}

koopa_update_chemacs() { # {{{3
    koopa_update_app \
        --name='chemacs' \
        --name-fancy='Chemacs' \
        "$@"
}
