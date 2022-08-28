#!/usr/bin/env bash

koopa_check_shared_object() {
    # """
    # Check shared object file.
    # @note Updated 2022-08-27.
    #
    # @examples
    # > koopa_check_shared_object \
    # >     --file='/opt/koopa/bin/openssl'
    # > koopa_check_shared_object \
    # >     --name='libR' \
    # >     --prefix='/opt/koopa/opt/r/lib/R/lib'
    # """
    local app dict tool_args
    koopa_assert_has_args "$#"
    declare -A app
    declare -A dict=(
        ['file']=''
        ['name']=''
        ['prefix']=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict['file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['file']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict['file']}" ]]
    then
        koopa_assert_is_set \
            '--name' "${dict['name']}" \
            '--prefix' "${dict['prefix']}"
        if koopa_is_linux
        then
            dict['shared_ext']='so'
        elif koopa_is_macos
        then
            dict['shared_ext']='dylib'
        fi
        dict['file']="${dict['prefix']}/${dict['name']}.${dict['shared_ext']}"
    fi
    koopa_assert_is_file "${dict['file']}"
    tool_args=()
    if koopa_is_linux
    then
        app['tool']="$(koopa_linux_locate_ldd)"
    elif koopa_is_macos
    then
        app['tool']="$(koopa_macos_locate_otool)"
        tool_args+=('-L')
    fi
    [[ -x "${app['tool']}" ]] || return 1
    tool_args+=("${dict['file']}")
    "${app['tool']}" "${tool_args[@]}"
    return 0
}
