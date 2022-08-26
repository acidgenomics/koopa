#!/usr/bin/env bash

koopa_armadillo_version() {
    # """
    # Armadillo: C++ library for linear algebra & scientific computing.
    # @note Updated 2022-08-26.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --app-name='armadillo' \
        --pc-name='armadillo'
}
