#!/usr/bin/env bash

koopa_install_armadillo() { # {{{3
    koopa_install_app \
        --name-fancy='Armadillo' \
        --name='armadillo' \
        "$@"
}

koopa_uninstall_armadillo() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Armadillo' \
        --name='armadillo' \
        "$@"
}
