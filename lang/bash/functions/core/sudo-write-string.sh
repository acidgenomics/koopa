#!/usr/bin/env bash

_koopa_sudo_write_string() {
    # """
    # Write a string to disk using root user.
    # @note Updated 2023-05-01.
    #
    # Alternative approach:
    # > sudo sh -c "printf '%s\n' '$string' > '${file}'"
    # """
    local -A app dict
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['file']=''
    dict['string']=''
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
            '--string='*)
                dict['string']="${1#*=}"
                shift 1
                ;;
            '--string')
                dict['string']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--file' "${dict['file']}" \
        '--string' "${dict['string']}"
    dict['parent_dir']="$(_koopa_dirname "${dict['file']}")"
    if [[ ! -d "${dict['parent_dir']}" ]]
    then
        _koopa_mkdir --sudo "${dict['parent_dir']}"
    fi
    if [[ ! -f "${dict['file']}" ]]
    then
        _koopa_touch --sudo "${dict['file']}"
    fi
    _koopa_print "${dict['string']}" \
        | _koopa_sudo "${app['tee']}" "${dict['file']}" >/dev/null
    return 0
}
