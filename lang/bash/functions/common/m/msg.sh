#!/usr/bin/env bash

koopa_msg() {
    # """
    # Standard message generator.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    local string
    dict['c1']="$(koopa_ansi_escape "${1:?}")"
    dict['c2']="$(koopa_ansi_escape "${2:?}")"
    dict['nc']="$(koopa_ansi_escape 'nocolor')"
    dict['prefix']="${3:?}"
    shift 3
    for string in "$@"
    do
        koopa_print "${dict['c1']}${dict['prefix']}${dict['nc']} \
${dict['c2']}${string}${dict['nc']}"
    done
    return 0
}
