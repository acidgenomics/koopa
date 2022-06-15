#!/usr/bin/env bash

koopa_armadillo_version() {
    # """
    # Armadillo: C++ library for linear algebra & scientific computing.
    # @note Updated 2022-06-15.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --opt-name='armadillo' \
        --pc-name='armadillo'
}
