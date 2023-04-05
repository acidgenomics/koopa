#!/usr/bin/env bash

koopa_brew_uninstall_all_brews() {
    # """
    # Uninstall all Homebrew formulae.
    # @note Updated 2022-04-22.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/198623
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    app['wc']="$(koopa_locate_wc)"
    [[ -x "${app['brew']}" ]] || exit 1
    [[ -x "${app['wc']}" ]] || exit 1
    while [[ "$("${app['brew']}" list --formulae | "${app['wc']}" -l)" -gt 0 ]]
    do
        local brews
        readarray -t brews <<< "$("${app['brew']}" list --formulae)"
        "${app['brew']}" uninstall \
            --force \
            --ignore-dependencies \
            "${brews[@]}"
    done
    return 0
}
