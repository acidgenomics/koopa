#!/usr/bin/env bash

# FIXME Rework this using 'koopa::str_match_perl'.
koopa::macos_ifactive() { # {{{1
    # """
    # Display active interfaces.
    # @note Updated 2021-10-25.
    # """
    local pcregrep x
    koopa::assert_is_installed 'ifconfig' 'pcregrep'
    pcregrep="$(koopa::locate_pcregrep)"
    x="$( \
        ifconfig \
            | "$pcregrep" -M -o '^[^\t:]+:([^\n]|\n\t)*status: active' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
