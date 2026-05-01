#!/usr/bin/env bash

_koopa_brew_uninstall_all_brews() {
    # """
    # Uninstall all Homebrew formulae.
    # @note Updated 2022-04-22.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/198623
    # """
    local -A app
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    app['wc']="$(_koopa_locate_wc)"
    _koopa_assert_is_executable "${app[@]}"
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
