#!/usr/bin/env bash

koopa_brew_outdated() {
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2021-10-27.
    # """
    local app str
    local -A app
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    str="$("${app['brew']}" outdated --quiet)"
    koopa_print "$str"
    return 0
}
