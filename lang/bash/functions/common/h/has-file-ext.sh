#!/usr/bin/env bash

koopa_has_file_ext() {
    # """
    # Does the input contain a file extension?
    # @note Updated 2022-02-17.
    #
    # @examples
    # > koopa_has_file_ext 'hello.txt'
    # """
    local file
    koopa_assert_has_args "$#"
    for file in "$@"
    do
        koopa_str_detect_fixed \
            --string="$(koopa_print "$file")" \
            --pattern='.' \
        || return 1
    done
    return 0
}
