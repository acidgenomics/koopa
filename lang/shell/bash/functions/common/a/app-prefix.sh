#!/usr/bin/env bash

koopa_app_prefix() {
    # """
    # Application prefix.
    # @note Updated 2022-07-26.
    #
    # @examples
    # > koopa_app_prefix
    # # /opt/koopa
    # > koopa_app_prefix 'r'
    # # /opt/koopa/app/r/4.2.1
    # """
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict
    dict['name']="${1:-}"
    if [[ -n "${dict['name']}" ]]
    then
        dict['opt_prefix']="$(koopa_opt_prefix)"
        dict['str']="${dict['opt_prefix']}/${dict['name']}"
        [[ -d "${dict['str']}" ]] || return 1
        dict['str']="$(koopa_realpath "${dict['str']}")"
    else
        dict['str']="$(koopa_koopa_prefix)/app"
    fi
    koopa_print "${dict['str']}"
    return 0
}
