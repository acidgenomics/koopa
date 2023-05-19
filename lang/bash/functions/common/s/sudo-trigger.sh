#!/usr/bin/env bash

koopa_sudo_trigger() {
    # """
    # Trigger sudo level permissions.
    # @note Updated 2023-05-18.
    #
    # This will prompt for password even when passwordless sudo is configured.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_is_root && return 0
    koopa_has_passwordless_sudo && return 0
    koopa_is_admin || return 1
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app['sudo']}"
    "${app['sudo']}" -v
    return 0
}
