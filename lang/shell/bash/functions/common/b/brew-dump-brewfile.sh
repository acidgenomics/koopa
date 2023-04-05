#!/usr/bin/env bash

koopa_brew_dump_brewfile() {
    # """
    # Dump a Homebrew Bundle Brewfile.
    # @note Updated 2021-10-27.
    # """
    local app today
    declare -A app
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    [[ -x "${app['brew']}" ]] || return 1
    today="$(koopa_today)"
    "${app['brew']}" bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}
