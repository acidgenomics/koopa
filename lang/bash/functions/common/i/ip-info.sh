#!/usr/bin/env bash

koopa_ip_info() {
    # """
    # IP information.
    # @note Updated 2023-07-07.
    #
    # @seealso
    # - https://askubuntu.com/questions/958360/
    # - https://askubuntu.com/questions/95910/
    # """
    local -A app dict
    app['curl']="$(koopa_locate_curl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['server']='ipinfo.io'
    dict['json']="$( \
        "${app['curl']}" \
            --disable \
            --silent \
            "${dict['server']}" \
    )"
    [[ -n "${dict['json']}" ]] || return 1
    koopa_print "${dict['json']}"
    return 0
}
