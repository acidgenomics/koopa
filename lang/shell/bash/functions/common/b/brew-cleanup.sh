#!/usr/bin/env bash

koopa_brew_cleanup() {
    # """
    # Clean up Homebrew.
    # @note Updated 2022-02-28.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    koopa_alert 'Cleaning up Homebrew install.'
    "${app[brew]}" cleanup -s || true
    koopa_rm "$("${app[brew]}" --cache)"
    "${app[brew]}" autoremove || true
    return 0
}
