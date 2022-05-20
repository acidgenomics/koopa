#!/usr/bin/env bash

koopa_brew_uninstall_all_brews() {
    # """
    # Uninstall all Homebrew formulae.
    # @note Updated 2022-04-22.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/198623
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [wc]="$(koopa_locate_wc)"
    )
    while [[ "$("${app[brew]}" list --formulae | "${app[wc]}" -l)" -gt 0 ]]
    do
        local brews
        readarray -t brews <<< "$("${app[brew]}" list --formulae)"
        "${app[brew]}" uninstall \
            --force \
            --ignore-dependencies \
            "${brews[@]}"
    done
    return 0
}
