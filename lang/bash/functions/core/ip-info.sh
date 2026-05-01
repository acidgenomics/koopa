#!/usr/bin/env bash

_koopa_ip_info() {
    # """
    # IP information.
    # @note Updated 2023-07-07.
    #
    # @seealso
    # - https://askubuntu.com/questions/958360/
    # - https://askubuntu.com/questions/95910/
    # """
    local -A app dict
    app['curl']="$(_koopa_locate_curl --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['server']='ipinfo.io'
    dict['json']="$( \
        "${app['curl']}" \
            --disable \
            --silent \
            "${dict['server']}" \
    )"
    [[ -n "${dict['json']}" ]] || return 1
    _koopa_print "${dict['json']}"
    return 0
}
