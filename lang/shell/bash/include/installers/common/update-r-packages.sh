#!/usr/bin/env bash

koopa:::update_r_packages() { # {{{1
    # """
    # Update R packages.
    # @note Updated 2022-02-10.
    # """
    koopa::assert_has_no_args "$#"
    # Return with success even if 'BiocManager::valid()' check returns false.
    koopa::r_koopa 'cliUpdateRPackages' "$@" || true
    return 0
}
