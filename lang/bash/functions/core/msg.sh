#!/usr/bin/env bash

_koopa_msg() {
    # """
    # Standard message generator.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    local string
    dict['c1']="$(_koopa_ansi_escape "${1:?}")"
    dict['c2']="$(_koopa_ansi_escape "${2:?}")"
    dict['nc']="$(_koopa_ansi_escape 'nocolor')"
    dict['prefix']="${3:?}"
    shift 3
    for string in "$@"
    do
        _koopa_print "${dict['c1']}${dict['prefix']}${dict['nc']} \
${dict['c2']}${string}${dict['nc']}"
    done
    return 0
}
