#!/usr/bin/env bash

koopa::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2020-12-08.
    # """
    koopa::rscript 'install-r-packages' "$@"
    return 0
}

koopa::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2020-11-17.
    # """
    koopa::rscript 'update-r-packages' "$@"
    return 0
}
