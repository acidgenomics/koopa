#!/usr/bin/env bash

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
