#!/usr/bin/env bash

main() {
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
