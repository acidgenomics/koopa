#!/usr/bin/env bash

_koopa_check_shared_object() {
    # """
    # Check shared object file.
    # @note Updated 2022-08-27.
    #
    # @examples
    # > _koopa_check_shared_object \
    # >     --file='/opt/koopa/bin/openssl'
    # > _koopa_check_shared_object \
    # >     --name='libR' \
    # >     --prefix='/opt/koopa/opt/r/lib/R/lib'
    # """
    local -A app dict
    local -a tool_args
    _koopa_assert_has_args "$#"
    dict['file']=''
    dict['name']=''
    dict['prefix']=''
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -z "${dict['file']}" ]]
    then
        _koopa_assert_is_set \
            '--name' "${dict['name']}" \
            '--prefix' "${dict['prefix']}"
        if _koopa_is_linux
        then
            dict['shared_ext']='so'
        elif _koopa_is_macos
        then
            dict['shared_ext']='dylib'
        fi
        dict['file']="${dict['prefix']}/${dict['name']}.${dict['shared_ext']}"
    fi
    _koopa_assert_is_file "${dict['file']}"
    tool_args=()
    if _koopa_is_linux
    then
        app['tool']="$(_koopa_linux_locate_ldd)"
    elif _koopa_is_macos
    then
        app['tool']="$(_koopa_macos_locate_otool)"
        tool_args+=('-L')
    fi
    _koopa_assert_is_executable "${app[@]}"
    tool_args+=("${dict['file']}")
    "${app['tool']}" "${tool_args[@]}"
    return 0
}
