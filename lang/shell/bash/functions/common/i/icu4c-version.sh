#!/usr/bin/env bash

koopa_icu4c_version() {
    # """
    # ICU version.
    # C/C++ and Java libraries for Unicode and globalization.
    # @note Updated 2021-09-15.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config 'icu-uc'
}
