#!/usr/bin/env bash

_koopa_status() {
    # """
    # Koopa status.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    local string
    _koopa_assert_has_args_ge "$#" 3
    dict['label']="$(printf '%10s\n' "${1:?}")"
    dict['color']="$(_koopa_ansi_escape "${2:?}")"
    dict['nocolor']="$(_koopa_ansi_escape 'nocolor')"
    shift 2
    for string in "$@"
    do
        string="${dict['color']}${dict['label']}${dict['nocolor']} | ${string}"
        _koopa_print "$string"
    done
    return 0
}
