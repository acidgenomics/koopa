#!/usr/bin/env bash

main() {
    # """
    # Update R packages.
    # @note Updated 2022-02-10.
    # """
    koopa_assert_has_no_args "$#"
    # Return with success even if 'BiocManager::valid()' check returns false.
    koopa_r_koopa 'cliUpdateRPackages' "$@" || true
    return 0
}
