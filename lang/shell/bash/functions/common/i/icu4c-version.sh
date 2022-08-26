#!/usr/bin/env bash

koopa_icu4c_version() {
    # """
    # ICU version.
    # @note Updated 2022-08-26.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --app-name='icu4c' \
        --pc-name='icu-uc'
}
