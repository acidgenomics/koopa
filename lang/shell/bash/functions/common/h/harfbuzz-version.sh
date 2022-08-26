#!/usr/bin/env bash

koopa_harfbuzz_version() {
    # """
    # HarfBuzz (libharfbuzz) version.
    # @note Updated 2022-08-26.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config \
        --app-name='harfbuzz' \
        --pc-name='harfbuzz'
}
