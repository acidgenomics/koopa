#!/bin/sh

_koopa_boolean_nounset() {
    # """
    # Return '0' (false) / '1' (true) boolean whether nounset mode is enabled.
    # @note Updated 2023-03-11.
    #
    # @details
    # Intended for [ "$x" -eq 1 ] (true) checks.
    #
    # This approach is the opposite of POSIX shell status codes, where 0 is
    # true and 1 is false.
    # """
    if _koopa_is_set_nounset
    then
        __kvar_bool=1
    else
        __kvar_bool=0
    fi
    _koopa_print "$__kvar_bool"
    unset -v __kvar_bool
    return 0
}
