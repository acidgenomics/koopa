#!/usr/bin/env bash

koopa_sys_group_name() {
    # """
    # Return the appropriate group name to use with koopa installation.
    # @note Updated 2023-03-26.
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
        group="$(koopa_admin_group_name)"
    else
        group="$(koopa_group_name)"
    fi
    koopa_print "$group"
    return 0
}
