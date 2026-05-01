#!/usr/bin/env bash

_koopa_has_file_ext() {
    # """
    # Does the input contain a file extension?
    # @note Updated 2022-02-17.
    #
    # @examples
    # > _koopa_has_file_ext 'hello.txt'
    # """
    local file
    _koopa_assert_has_args "$#"
    for file in "$@"
    do
        _koopa_str_detect_fixed \
            --string="$(_koopa_print "$file")" \
            --pattern='.' \
        || return 1
    done
    return 0
}
