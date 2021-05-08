#!/usr/bin/env bash

koopa::macos_spotlight_find() { # {{{1
    # """
    # Find files using Spotlight index, instead of GNU find.
    # @note Updated 2021-05-08.
    # """
    local pattern x
    koopa::assert_has_args_le "$#" 2
    koopa::assert_is_installed mdfind
    pattern="${1:?}"
    dir="${2:-.}"
    koopa::assert_is_dir "$dir"
    x="$( \
        mdfind \
        -name "$pattern" \
        -onlyin "$dir" \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
