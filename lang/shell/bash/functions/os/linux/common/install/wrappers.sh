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

koopa::linux_install_ruby() { # {{{1
    koopa::linux_install_app \
        --name='ruby' \
        --name-fancy='Ruby' \
        "$@"
}

koopa::linux_install_taglib() { # {{{1
    koopa::linux_install_app \
        --name='taglib' \
        --name-fancy='TagLib' \
        "$@"
}

koopa::linux_install_udunits() { # {{{1
    koopa::linux_install_app \
        --name='udunits' \
        "$@"
}

koopa::linux_install_vim() { # {{{1
    koopa::linux_install_app \
        --name='vim' \
        --name-fancy='Vim' \
        "$@"
}
