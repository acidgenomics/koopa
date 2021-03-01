#!/usr/bin/env bash

koopa::linux_version() { # {{{1
    # """
    # Linux version.
    # @note Updated 2020-08-06.
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="$(uname -r)"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
