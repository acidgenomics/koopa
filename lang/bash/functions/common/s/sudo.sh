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
    local orig_umask
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    koopa_assert_has_args "$#"
    orig_umask="$(umask)"
    # Ensure scripts run as admin generate files with expected permissions.
    # Using a more restrictive umask such as 0077 here can break some install
    # and configuration scripts.
    umask 0022
    if ! koopa_is_root
    then
        koopa_assert_is_admin
        app['sudo']="$(koopa_locate_sudo)"
        koopa_assert_is_executable "${app[@]}"
        cmd+=("${app['sudo']}")
    fi
    cmd+=("$@")
    "${cmd[@]}"
    umask "$orig_umask"
    return 0
}
