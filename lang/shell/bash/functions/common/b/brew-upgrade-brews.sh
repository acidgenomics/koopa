#!/usr/bin/env bash

koopa_brew_upgrade_brews() {
    # """
    # Upgrade outdated Homebrew brews.
    # @note Updated 2022-02-16.
    # """
    local app brew brews
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
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
    for brew in "${brews[@]}"
    do
        "${app[brew]}" reinstall --force "$brew" || true
        # Ensure specific brews are properly linked on macOS.
        if koopa_is_macos
        then
            case "$brew" in
                'gcc' | \
                'gpg' | \
                'python@3.9' | \
                'vim')
                    "${app[brew]}" link --overwrite "$brew" || true
                    ;;
            esac
        fi
    done
    return 0
}
