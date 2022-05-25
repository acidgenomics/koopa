#!/usr/bin/env bash

koopa_macos_finder_unhide() {
    # """
    # Unhide files from view in the Finder.
    # @note Updated 2022-05-20.
    # """
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [setfile]="$(koopa_macos_locate_setfile)"
    )
    [[ -x "${app[setfile]}" ]] || return 1
    koopa_assert_is_existing "$@"
    "${app[setfile]}" -a v "$@"
    return 0
}
