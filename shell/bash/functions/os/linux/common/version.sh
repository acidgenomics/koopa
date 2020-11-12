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

koopa::lmod_version() { # {{{1
    # """
    # Lmod version.
    # @note Updated 2020-06-29.
    #
    # Alterate approach:
    # > module --version 2>&1 \
    # >     | grep -Eo 'Version [.0-9]+' \
    # >     | cut -d ' ' -f 2
    # """
    local x
    koopa::assert_has_no_args "$#"
    x="${LMOD_VERSION:-}"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
