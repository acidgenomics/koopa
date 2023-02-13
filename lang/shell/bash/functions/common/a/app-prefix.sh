#!/usr/bin/env bash

koopa_app_prefix() {
    # """
    # Application prefix.
    # @note Updated 2023-01-03.
    #
    # @examples
    # > koopa_app_prefix
    # # /opt/koopa/app
    # > koopa_app_prefix 'python3.10' 'r'
    # # /opt/koopa/app/python3.10/3.10.6
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
        local dict2
        declare -A dict2
        dict2['app_name']="$app_name"
        dict2['version']="$( \
            koopa_app_json_version "${dict2['app_name']}" || true \
        )"
        if [[ -z "${dict2['version']}" ]]
        then
            koopa_stop "Unsupported app: '${dict2['app_name']}'."
        fi
        # Shorten git commit to 7 characters.
        if [[ "${#dict2['version']}" == 40 ]]
        then
            dict2['version']="${dict2['version']:0:7}"
        fi
        dict2['prefix']="${dict['app_prefix']}/${dict2['app_name']}/\
${dict2['version']}"
        if [[ "${dict['allow_missing']}" -eq 0 ]]
        then
            koopa_assert_is_dir "${dict2['prefix']}"
        fi
        if [[ -d "${dict2['prefix']}" ]]
        then
            dict2['prefix']="$(koopa_realpath "${dict2['prefix']}")"
        fi
        koopa_print "${dict2['prefix']}"
    done
    return 0
}
