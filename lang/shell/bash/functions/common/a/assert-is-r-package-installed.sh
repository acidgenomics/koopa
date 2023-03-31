#!/usr/bin/env bash

# FIXME Need to allow user to specify with R.

koopa_assert_is_r_package_installed() {
    # """
    # Assert that specific R packages are installed.
    # @note Updated 2022-10-07.
    # """
    koopa_assert_has_args "$#"
    if ! koopa_is_r_package_installed "$@"
    then
        koopa_stop "Required R packages missing: ${*}."
    fi
    return 0
}
