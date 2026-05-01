#!/usr/bin/env bash

_koopa_assert_is_matching_fixed() {
    # """
    # Assert that input matches a fixed pattern.
    # @note Updated 2023-03-12.
    # """
    local -A dict
    _koopa_assert_has_args "$#"
    dict['pattern']=''
    dict['string']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
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
        '--pattern' "${dict['pattern']}" \
        '--string' "${dict['string']}"
    if ! _koopa_str_detect_fixed \
        --pattern="${dict['pattern']}" \
        --string="${dict['string']}"
    then
        _koopa_stop "'${dict['string']}' doesn't match '${dict['pattern']}'."
    fi
    return 0
}
