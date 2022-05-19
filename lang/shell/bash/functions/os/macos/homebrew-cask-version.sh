#!/usr/bin/env bash

koopa_macos_homebrew_cask_version() {
    # """
    # Get Homebrew Cask version.
    # @note Updated 2022-05-19.
    #
    # @examples
    # > koopa_macos_homebrew_cask_version 'gpg-suite'
    # # 2019.2
    # """
    local app cask x
    koopa_assert_has_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    [[ -x "${app[brew]}" ]] || return 1
    for cask in "$@"
    do
        x="$("${app[brew]}" info --cask "$cask")"
        x="$(koopa_extract_version "$x")"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}
