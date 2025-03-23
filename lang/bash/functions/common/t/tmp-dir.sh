#!/usr/bin/env bash

koopa_tmp_dir() {
    # """
    # Create temporary directory.
    # @note Updated 2022-06-22.
    # """
    local x
    koopa_assert_has_no_args "$#"
    x="$(koopa_mktemp -d)"
    koopa_assert_is_dir "$x"
    x="$(koopa_realpath "$x")"
    koopa_print "$x"
    return 0
}
