#!/usr/bin/env bash

koopa_gpg_reload() {
    # """
    # Force reload the GPG server.
    # @note Updated 2022-05-20.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [gpg_connect_agent]="$(koopa_locate_gpg_connect_agent)"
    )
    [[ -x "${app[gpg_connect_agent]}" ]] || return 1
    "${app[gpg_connect_agent]}" reloadagent '/bye'
    return 0
}
