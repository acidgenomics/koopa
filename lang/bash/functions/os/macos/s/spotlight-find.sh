#!/usr/bin/env bash

koopa_macos_spotlight_find() {
    # """
    # Find files using Spotlight index.
    # @note Updated 2021-05-20.
    # """
    local pattern x
    koopa_assert_has_args_le "$#" 2
    koopa_assert_is_installed 'mdfind'
    pattern="${1:?}"
    dir="${2:-.}"
    koopa_assert_is_dir "$dir"
    x="$( \
        mdfind \
            -name "$pattern" \
            -onlyin "$dir" \
    )"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}
