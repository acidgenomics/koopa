#!/usr/bin/env bash

koopa_brew_outdated() {
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2021-10-27.
    # """
    local app x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    x="$("${app[brew]}" outdated --quiet)"
    koopa_print "$x"
    return 0
}
