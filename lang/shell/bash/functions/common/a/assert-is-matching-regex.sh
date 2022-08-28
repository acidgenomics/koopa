#!/usr/bin/env bash

koopa_assert_is_matching_regex() {
    # """
    # Assert that input matches a regular expression pattern.
    # @note Updated 2022-02-27.
    # """
    declare -A dict=(
        ['pattern']=''
        ['string']=''
    )
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--pattern' "${dict['pattern']}" \
        '--string' "${dict['string']}"
    if ! koopa_str_detect_regex \
        --pattern="${dict['pattern']}" \
        --string="${dict['string']}"
    then
        koopa_stop "'${dict['string']}' doesn't match regex '${dict['pattern']}'."
    fi
    return 0
}
