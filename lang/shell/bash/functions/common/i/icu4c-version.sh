#!/usr/bin/env bash

koopa_icu4c_version() {
    # """
    # ICU version.
    # @note Updated 2022-06-15.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --opt-name='icu4c' \
        --pc-name='icu-uc'
}
