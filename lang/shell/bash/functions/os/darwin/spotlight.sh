#!/usr/bin/env bash

koopa::macos_spotlight_find() { # {{{1
    # """
    # Find files using Spotlight index, instead of GNU find.
    # @note Updated 2021-05-08.
    # """
    local x
    koopa::assert_has_args "$#"
    koopa::assert_is_installed mdfind
    x="$(mdfind -name "$@")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
