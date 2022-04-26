#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install wget.
    # @note Updated 2022-04-25.
    #
    # """
    koopa_install_app \
        --no-link-in-opt \
        --no-prefix-check \
        --quiet \
        "$@"
}
