#!/usr/bin/env bash

koopa_brew_dump_brewfile() {
    # """
    # Dump a Homebrew Bundle Brewfile.
    # @note Updated 2021-10-27.
    # """
    local -A app
    local today
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    today="$(koopa_today)"
    "${app['brew']}" bundle dump \
        --file="brewfile-${today}" \
        --force
    return 0
}
