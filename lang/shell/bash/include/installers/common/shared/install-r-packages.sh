#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2022-02-10.
    # """
    koopa_r_koopa 'cliInstallRPackages' "$@"
    return 0
}
