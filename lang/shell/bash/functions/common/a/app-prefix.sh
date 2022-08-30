#!/usr/bin/env bash

koopa_app_prefix() {
    # """
    # Application prefix.
    # @note Updated 2022-08-29.
    #
    # @examples
    # > koopa_app_prefix
    # # /opt/koopa/app
    # > koopa_app_prefix 'python' 'r'
    # # /opt/koopa/app/python/3.10.6
    # # /opt/koopa/app/r/4.2.1
    # """
    local dict
    declare -A dict=(
        ['app_prefix']="$(koopa_koopa_prefix)/app"
    )
    if [[ "$#" -eq 0 ]]
    then
        koopa_print "${dict['app_prefix']}"
        return 0
    fi
    for app_name in "$@"
    do
        local prefix version
        version="$(koopa_app_json_version "$app_name" || true)"
        if [[ -z "$version" ]]
        then
            koopa_stop "Unsupported app: '${app_name}'."
        fi
        prefix="${dict['app_prefix']}/${app_name}/${version}"
        koopa_assert_is_dir "$prefix"
        koopa_print "$prefix"
    done
    return 0
}
