#!/usr/bin/env bash

koopa_app_prefix() {
    # """
    # Application prefix.
    # @note Updated 2023-07-28.
    #
    # @examples
    # > koopa_app_prefix
    # # /opt/koopa/app
    # > koopa_app_prefix 'r' 'ruby'
    # # /opt/koopa/app/r/4.3.1
    # # /opt/koopa/app/ruby/3.2.2
    # """
    local -A dict
    local -a pos
    dict['allow_missing']=0
    dict['app_prefix']="$(koopa_koopa_prefix)/app"
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
        local -A dict2
        dict2['app_name']="$app_name"
        dict2['version']="$( \
            koopa_app_json_version "${dict2['app_name']}" \
            2>/dev/null \
            || true \
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
        if [[ ! -d "${dict2['prefix']}" ]] && \
            [[ "${dict['allow_missing']}" -eq 1 ]]
        then
            continue
        fi
        koopa_assert_is_dir "${dict2['prefix']}"
        dict2['prefix']="$(koopa_realpath "${dict2['prefix']}")"
        koopa_print "${dict2['prefix']}"
    done
    return 0
}
