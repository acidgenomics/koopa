#!/usr/bin/env bash

koopa_strip_left() {
    # """
    # Strip pattern from left side (start) of string.
    # @note Updated 2022-03-01.
    #
    # @usage koopa_strip_left --pattern=PATTERN STRING...
    #
    # @examples
    # > koopa_strip_left \
    # >     --pattern='The ' \
    # >     'The Quick Brown Fox' \
    # >     'The White Lady'
    # # Quick Brown Fox
    # # White Lady
    # """
    local dict pos str
    declare -A dict=(
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    [[ "${#pos[@]}" -eq 0 ]] && pos=("$(</dev/stdin)")
    for str in "${pos[@]}"
    do
        printf '%s\n' "${str##"${dict[pattern]}"}"
    done
    return 0
}
