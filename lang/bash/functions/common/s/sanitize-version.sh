#!/usr/bin/env bash

koopa_sanitize_version() {
    # """
    # Sanitize version.
    # @note Updated 2022-04-25.
    #
    # @examples
    # > koopa_sanitize_version '2.7.1p83'
    # # 2.7.1
    # """
    local str
    koopa_assert_has_args "$#"
    for str in "$@"
    do
        koopa_str_detect_regex \
            --string="$str" \
            --pattern='[.0-9]+' \
            || return 1
        str="$( \
            koopa_sub \
                --pattern='^([.0-9]+).*$' \
                --regex \
                --replacement='\1' \
                "$str" \
        )"
        koopa_print "$str"
    done
    return 0
}
