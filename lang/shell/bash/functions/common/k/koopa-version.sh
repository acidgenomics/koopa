#!/usr/bin/env bash

koopa_koopa_version() {
    # """
    # Koopa version.
    # @note Updated 2020-06-29.
    # """
    koopa_assert_has_no_args "$#"
    koopa_variable 'koopa-version'
    return 0
}
