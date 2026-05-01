#!/usr/bin/env bash

_koopa_brew_upgrade_brews() {
    # """
    # Upgrade outdated Homebrew brews.
    # @note Updated 2025-11-12.
    # """
    local -A app
    local -a brews
    local brew
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Checking brews.'
    readarray -t brews <<< "$(_koopa_brew_outdated)"
    _koopa_is_array_non_empty "${brews[@]:-}" || return 0
    _koopa_dl \
        "$(_koopa_ngettext \
            --num="${#brews[@]}" \
            --middle=' outdated ' \
            --msg1='brew' \
            --msg2='brews' \
        )" \
        "$(_koopa_to_string "${brews[@]}")"
    "${app['brew']}" reinstall --force "${brews[@]}"
    return 0
}
