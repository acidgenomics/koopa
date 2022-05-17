#!/usr/bin/env bash

koopa_tmp_file() {
    # """
    # Create temporary file.
    # @note Updated 2021-05-06.
    # """
    local x
    koopa_assert_has_no_args "$#"
    x="$(koopa_mktemp)"
    koopa_assert_is_file "$x"
    koopa_print "$x"
    return 0
}
