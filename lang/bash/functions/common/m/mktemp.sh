#!/usr/bin/env bash

koopa_mktemp() {
    # """
    # Wrapper function for system 'mktemp'.
    # @note Updated 2023-09-23.
    # """
    local -A app dict
    app['mktemp']="$(koopa_locate_mktemp --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['str']="$("${app['mktemp']}" "$@")"
    [[ -e "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}
