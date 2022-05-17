#!/usr/bin/env bash

koopa_cairo_version() {
    # """
    # Cairo (libcairo) version.
    # @note Updated 2021-03-01.
    # """
    koopa_assert_has_no_args "$#"
    koopa_get_version_from_pkg_config 'cairo'
}
