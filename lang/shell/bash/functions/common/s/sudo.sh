#!/usr/bin/env bash

koopa_sudo() {
    # """
    # Execute command as a system admin.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://www.sudo.ws/
    # - https://github.com/tianon/gosu/
    # """
    local -A app
    local -a cmd
    koopa_assert_has_args "$#"
    if ! koopa_is_root
    then
        app['sudo']="$(koopa_locate_sudo)"
        koopa_assert_is_executable "${app[@]}"
        cmd+=("${app['sudo']}")
    fi
    cmd+=("$@")
    "${cmd[@]}"
    return 0
}
