#!/usr/bin/env bash

koopa_harfbuzz_version() {
    # """
    # HarfBuzz (libharfbuzz) version.
    # @note Updated 2022-06-15.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --opt-name='harfbuzz' \
        --pc-name='harfbuzz'
}
