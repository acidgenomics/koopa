#!/usr/bin/env bash

koopa::update_r_packages() { # {{{1
    # """
    # Update R packages
    # @note Updated 2020-11-17.
    # """
    koopa::rscript 'update-r-packages'
    return 0
}
