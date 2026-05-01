#!/usr/bin/env bash

_koopa_append_string() {
    # """
    # Append a string at end of file.
    # @note Updated 2022-03-01.
    # """
    local -A dict
    _koopa_assert_has_args "$#"
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
    if [[ ! -f "${dict['file']}" ]]
    then
        _koopa_mkdir "$(_koopa_dirname "${dict['file']}")"
        _koopa_touch "${dict['file']}"
    fi
    _koopa_print "${dict['string']}" >> "${dict['file']}"
    return 0
}
