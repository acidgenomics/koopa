#!/usr/bin/env bash

koopa_sys_group() {
    # """
    # Return the appropriate group to use with koopa installation.
    # @note Updated 2020-07-04.
    #
    # Returns current user for local install.
    # Dynamically returns the admin group for shared install.
    #
    # Admin group priority: admin (macOS), sudo (Debian), wheel (Fedora).
    # """
    local group
    koopa_assert_has_no_args "$#"
    if koopa_is_shared_install
    then
        group="$(koopa_admin_group)"
    else
        group="$(koopa_group)"
    fi
    koopa_print "$group"
    return 0
}
