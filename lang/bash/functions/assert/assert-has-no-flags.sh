#!/usr/bin/env bash

_koopa_assert_has_no_flags() {
    # """
    # Assert that the user input does not contain flags.
    # @note Updated 2023-03-12.
    # """
    _koopa_assert_has_args "$#"
    while (("$#"))
    do
        case "$1" in
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                shift 1
                ;;
        esac
    done
    return 0
}
