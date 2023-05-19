#!/usr/bin/env bash

koopa_strip_right() {
    # """
    # Strip pattern from right side (end) of string.
    # @note Updated 2023-04-05.
    #
    # @usage koopa_strip_right --pattern=PATTERN STRING...
    #
    # @examples
    # > koopa_strip_right \
    # >     --pattern=' Fox' \
    # >     'The Quick Brown Fox' \
    # >     'Michael J. Fox'
    # # The Quick Brown
    # # Michael J.
    # """
    local -A dict
    local -a pos
    local str
    dict['pattern']=''
    pos=()
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
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    for str in "$@"
    do
        printf '%s\n' "${str%%"${dict['pattern']}"}"
    done
    return 0
}
