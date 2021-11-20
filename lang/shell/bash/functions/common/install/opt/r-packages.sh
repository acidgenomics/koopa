#!/usr/bin/env bash

koopa:::install_r_packages() { # {{{1
    # """
    # Install R packages.
    # @note Updated 2021-09-16.
    # """
    koopa::configure_r
    koopa::r_koopa 'cliInstallRPackages' "$@"
    return 0
}

koopa:::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2021-09-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::configure_r
    # Return with success even if 'BiocManager::valid()' check returns false.
    koopa::r_koopa 'cliUpdateRPackages' "$@" || true
    return 0
}
