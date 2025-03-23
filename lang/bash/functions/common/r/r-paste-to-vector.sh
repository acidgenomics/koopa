#!/usr/bin/env bash

koopa_r_paste_to_vector() {
    # """
    # Paste a bash array into an R vector string.
    # @note Updated 2022-02-17.
    # """
    local str
    koopa_assert_has_args "$#"
    str="$(printf '"%s", ' "$@")"
    str="$(koopa_strip_right --pattern=', ' "$str")"
    str="$(printf 'c(%s)\n' "$str")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}
