#!/bin/sh

_koopa_logged_in_user_count() {
    # """
    # Number of logged in users.
    # @note Updated 2023-09-14.
    #
    # Usage of 'who -q' is problematic when the same user is connected via
    # multiple SSH sessions. Need to filter this out.
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
    __kvar_string="$(_koopa_logged_in_users | wc -l)"
    [ -n "$__kvar_string" ] || return 1
    _koopa_print "$__kvar_string"
    unset -v __kvar_string
    return 0
}
