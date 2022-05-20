#!/usr/bin/env bash

koopa_assert_has_no_flags() {
    # """
    # Assert that the user input does not contain flags.
    # @note Updated 2021-09-20.
    # """
    while (("$#"))
    do
        case "$1" in
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                shift 1
                ;;
        esac
    done
    return 0
}
