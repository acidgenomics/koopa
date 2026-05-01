#!/usr/bin/env bash

_koopa_brew_outdated() {
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2021-10-27.
    # """
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    str="$("${app['brew']}" outdated --quiet)"
    _koopa_print "$str"
    return 0
}
