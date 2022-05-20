#!/bin/sh

koopa_boolean_nounset() {
    # """
    # Return 0 (false) / 1 (true) boolean whether nounset mode is enabled.
    # @note Updated 2020-07-05.
    #
    # Intended for [ "$x" -eq 1 ] (true) checks.
    #
    # This approach is the opposite of POSIX shell status codes, where 0 is
    # true and 1 is false.
    # """
    local bool
    if koopa_is_set_nounset
    then
        bool=1
    else
        bool=0
    fi
    koopa_print "$bool"
    return 0
}
