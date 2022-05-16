#!/usr/bin/env bash

koopa_lmod_version() {
    # """
    # Lmod version.
    # @note Updated 2022-02-23.
    # """
    local str
    koopa_assert_has_no_args "$#"
    str="${LMOD_VERSION:-}"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
