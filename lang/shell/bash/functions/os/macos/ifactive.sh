#!/usr/bin/env bash

koopa::macos_ifactive() { # {{{1
    # """
    # Display active interfaces.
    # @note Updated 2022-01-20.
    # """
    local app x
    declare -A app=(
        [ifconfig]="$(koopa::macos_locate_ifconfig)"
        [pcregrep]="$(koopa::locate_pcregrep)"
    )
    x="$( \
        "${app[ifconfig]}" \
            | "${app[pcregrep]}" -M -o '^[^\t:]+:([^\n]|\n\t)*status: active' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}
