#!/usr/bin/env bash

koopa_brew_upgrade_brews() {
    # """
    # Upgrade outdated Homebrew brews.
    # @note Updated 2025-11-12.
    # """
    local -A app
    local -a brews
    local brew
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert 'Checking brews.'
    readarray -t brews <<< "$(koopa_brew_outdated)"
    koopa_is_array_non_empty "${brews[@]:-}" || return 0
    koopa_dl \
        "$(koopa_ngettext \
            --num="${#brews[@]}" \
            --middle=' outdated ' \
            --msg1='brew' \
            --msg2='brews' \
        )" \
        "$(koopa_to_string "${brews[@]}")"
    "${app['brew']}" reinstall --force "${brews[@]}"
    return 0
}
