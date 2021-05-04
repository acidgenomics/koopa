#!/usr/bin/env bash

koopa::linux_install_r() { # {{{1
    koopa::linux_install_app \
        --name='r' \
        --name-fancy='R' \
        "$@"
}

# NOTE Consider changing 'name' to 'r-devel' here?
koopa::linux_install_r_devel() { # {{{1
    koopa::linux_install_app \
        --name='r' \
        --name-fancy='R' \
        --version='devel' \
        --script-name='r-devel' \
        "$@"
}
