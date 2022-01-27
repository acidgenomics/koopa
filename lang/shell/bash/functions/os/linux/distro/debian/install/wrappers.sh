#!/usr/bin/env bash

koopa::debian_install_bcbio_nextgen_vm() { # {{{1
    koopa::install_app \
        --name='bcbio-nextgen-vm' \
        --no-link \
        --platform='debian' \
        "$@"
}

koopa::debian_install_docker() { # {{{1
    koopa::install_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_install_r_devel() { # {{{1
    koopa::install_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --no-link \
        --platform='debian' \
        "$@"
}

koopa::debian_uninstall_bcbio_nextgen_vm() { # {{{1
    # """
    # Uninstall bcbio-nextgen-vm.
    # @note Updated 2021-11-02.
    # """
    koopa::uninstall_app \
        --name='bcbio-nextgen-vm' \
        --no-link \
        "$@"
}

koopa::debian_uninstall_docker() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_uninstall_r_devel() { # {{{1
    koopa::uninstall_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --no-link \
        --platform='debian' \
        "$@"
}

# FIXME Technically this isn't a wrapper. Need to rework.
koopa::debian_uninstall_shiny_server() { # {{{1
    # """
    # Uninstall Shiny Server.
    # @note Updated 2021-06-14.
    # """
    koopa::debian_apt_remove 'shiny-server'
}
