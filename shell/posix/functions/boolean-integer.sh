#!/bin/sh
# shellcheck disable=SC2039

_koopa_boolean_nounset() { # {{{1
    # """
    # Return 0 (false) / 1 (true) boolean whether nounset mode is enabled.
    # @note Updated 2020-06-30.
    #
    # Intended for [ "$x" -eq 1 ] (true) checks.
    #
    # This approach is the opposite of POSIX shell status codes, where 0 is
    # true and 1 is false.
    # """
    _koopa_assert_has_no_args "$#"
    local bool
    if _koopa_is_set_nounset
    then
        bool="1"
    else
        bool="0"
    fi
    _koopa_print "$bool"
    return 0
}
