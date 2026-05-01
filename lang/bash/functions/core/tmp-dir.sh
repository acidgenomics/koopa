#!/usr/bin/env bash

_koopa_tmp_dir() {
    # """
    # Create temporary directory.
    # @note Updated 2022-06-22.
    # """
    local x
    _koopa_assert_has_no_args "$#"
    x="$(_koopa_mktemp -d)"
    _koopa_assert_is_dir "$x"
    x="$(_koopa_realpath "$x")"
    _koopa_print "$x"
    return 0
}
