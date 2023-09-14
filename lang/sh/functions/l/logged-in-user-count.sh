#!/bin/sh

_koopa_logged_in_user_count() {
    # """
    # Number of logged in users.
    # @note Updated 2023-09-14.
    #
    # Return is inconsistent between BSD and Linux.
    #
    # BSD:
    # > # users = 1
    # Linux:
    # > # users=1
    #
    # @seealso
    # - man who
    # - man w
    # """
    __kvar_string="$(who -q | tail -n 1 | grep -Eo '[0-9]+$')"
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
