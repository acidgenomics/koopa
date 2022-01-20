#!/usr/bin/env bash

koopa::array_to_r_vector() { # {{{1
    # """
    # Convert a bash array to an R vector string.
    # @note Updated 2020-07-20.
    # """
    local x
    koopa::assert_has_args "$#"
    x="$(printf '"%s", ' "$@")"
    x="$(koopa::strip_right ', ' "$x")"
    x="$(printf 'c(%s)\n' "$x")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
