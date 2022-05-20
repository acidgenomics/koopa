#!/usr/bin/env bash

__koopa_status() {
    # """
    # Koopa status.
    # @note Updated 2021-11-18.
    # """
    local dict string
    koopa_assert_has_args_ge "$#" 3
    declare -A dict=(
        [label]="$(printf '%10s\n' "${1:?}")"
        [color]="$(__koopa_ansi_escape "${2:?}")"
        [nocolor]="$(__koopa_ansi_escape 'nocolor')"
    )
    shift 2
    for string in "$@"
    do
        string="${dict[color]}${dict[label]}${dict[nocolor]} | ${string}"
        koopa_print "$string"
    done
    return 0
}
