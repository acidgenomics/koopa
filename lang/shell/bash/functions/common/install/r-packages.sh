#!/usr/bin/env bash

koopa::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2021-01-19.
    # """
    koopa::h1 'Installing R packages.'
    koopa::rscript 'installRPackages' "$@"
    return 0
}

koopa::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2021-01-19.
    # """
    koopa::h1 'Updating R packages.'
    koopa::rscript 'updateRPackages' "$@"
    return 0
}
