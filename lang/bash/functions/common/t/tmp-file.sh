#!/usr/bin/env bash

koopa_tmp_file() {
    # """
    # Create temporary file.
    # @note Updated 2022-06-22.
    # """
    local x
    koopa_assert_has_no_args "$#"
    x="$(koopa_mktemp)"
    koopa_assert_is_file "$x"
    x="$(koopa_realpath "$x")"
    koopa_print "$x"
    return 0
}
