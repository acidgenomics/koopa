#!/usr/bin/env bash

_koopa_mktemp() {
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2023-09-23.
    # """
    local -A app dict
    app['mktemp']="$(_koopa_locate_mktemp --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['str']="$("${app['mktemp']}" "$@")"
    [[ -e "${dict['str']}" ]] || return 1
    _koopa_print "${dict['str']}"
    return 0
}
