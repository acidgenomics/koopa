#!/usr/bin/env bash

koopa_brew_reset_permissions() {
    # """
    # Reset permissions on Homebrew installation.
    # @note Updated 2023-03-27.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['group']="$(koopa_admin_group_name)"
    dict['prefix']="$(koopa_homebrew_prefix)"
    dict['user']="$(koopa_user_name)"
    koopa_alert "Resetting ownership of files in \
'${dict['prefix']}' to '${dict['user']}:${dict['group']}'."
    koopa_chown \
        --no-dereference \
        --recursive \
        --sudo \
        "${dict['user']}:${dict['group']}" \
        "${dict['prefix']}/"*
    return 0
}
