#!/bin/sh

_koopa_number_of_logged_in_users() {
    # """
    # Number of logged in users.
    # @note Updated 2023-09-14.
    #
    # @seealso
    # - man who
    # - man w
    # """
    __kvar_string="$(who -q | tail -n 1 | awk '{ print $NF }')"
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
