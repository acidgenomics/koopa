#!/usr/bin/env bash

koopa_sudo() {
    # """
    # Execute command as a system admin.
    # @note Updated 2024-06-27.
    #
    # @seealso
    # - https://www.sudo.ws/
    # - https://github.com/tianon/gosu/
    # """
    local -A app
    local -a cmd
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    koopa_assert_has_args "$#"
    if ! koopa_is_root
    then
        koopa_assert_is_admin
        app['sudo']="$(koopa_locate_sudo)"
        koopa_assert_is_executable "${app[@]}"
        cmd+=("${app['sudo']}")
    fi
    cmd+=("$@")
    "${cmd[@]}"
    return 0
}
