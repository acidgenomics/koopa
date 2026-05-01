#!/usr/bin/env bash

_koopa_int_to_yn() {
    # """
    # Convert integer to yes/no choice.
    # @note Updated 2022-02-09.
    # """
    local str
    _koopa_assert_has_args_eq "$#" 1
    case "${1:?}" in
        '0')
            str='no'
            ;;
        '1')
            str='yes'
            ;;
        *)
            _koopa_stop "Invalid choice: requires '0' or '1'."
            ;;
    esac
    _koopa_print "$str"
    return 0
}
