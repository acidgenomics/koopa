#!/usr/bin/env bash

koopa_is_url() {
    # """
    # Check if the input is a URL.
    # @note Updated 2023-11-03.
    #
    # @examples
    # # TRUE:
    # > koopa_is_url 'https://google.com/'
    #
    # # FALSE:
    # > koopa_is_url 'foo'
    # """
    local string
    koopa_assert_has_args "$#"
    for string in "$@"
    do
        koopa_str_detect_fixed \
            --pattern='://' \
            --string="$string" \
            || return 1
        continue
    done
    return 0
}
