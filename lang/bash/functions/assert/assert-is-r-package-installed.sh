#!/usr/bin/env bash

_koopa_assert_is_r_package_installed() {
    # """
    # Assert that specific R packages are installed.
    # @note Updated 2022-10-07.
    # """
    _koopa_assert_has_args "$#"
    if ! _koopa_is_r_package_installed "$@"
    then
        _koopa_stop "Required R packages missing: ${*}."
    fi
    return 0
}
