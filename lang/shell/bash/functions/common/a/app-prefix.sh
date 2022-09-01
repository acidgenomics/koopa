#!/usr/bin/env bash

koopa_app_prefix() {
    # """
    # Application prefix.
    # @note Updated 2022-09-01.
    #
    # @examples
    # > koopa_app_prefix
    # # /opt/koopa/app
    # > koopa_app_prefix 'python' 'r'
    # # /opt/koopa/app/python/3.10.6
    # # /opt/koopa/app/r/4.2.1
    # """
    local dict pos
    declare -A dict=(
        ['allow_missing']=0
        ['app_prefix']="$(koopa_koopa_prefix)/app"
    )
    if [[ "$#" -eq 0 ]]
    then
        koopa_print "${dict['app_prefix']}"
        return 0
    fi
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--allow-missing')
                dict['allow_missing']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '--'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    for app_name in "$@"
    do
        local prefix version
        version="$(koopa_app_json_version "$app_name" || true)"
        if [[ -z "$version" ]]
        then
            koopa_stop "Unsupported app: '${app_name}'."
        fi
        prefix="${dict['app_prefix']}/${app_name}/${version}"
        if [[ "${dict['allow_missing']}" -eq 0 ]]
        then
            koopa_assert_is_dir "$prefix"
        fi
        koopa_print "$prefix"
    done
    return 0
}
