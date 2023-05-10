#!/usr/bin/env bash

koopa_sudo_trigger() {
    # """
    # Trigger sudo level permissions.
    # @note Updated 2023-05-01.
    #
    # This will prompt for password even when passwordless sudo is configured.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    koopa_is_root && return 0
    koopa_assert_is_admin
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app['sudo']}"
    "${app['sudo']}" -v
    return 0
}
