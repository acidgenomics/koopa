#!/usr/bin/env bash

koopa_macos_homebrew_cask_version() {
    # """
    # Get Homebrew Cask version.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > koopa_macos_homebrew_cask_version 'gpg-suite'
    # # 2019.2
    # """
    local -A app
    local cask
    koopa_assert_has_args "$#"
    app['brew']="$(koopa_locate_brew)"
    koopa_assert_is_executable "${app[@]}"
    for cask in "$@"
    do
        local str
        str="$("${app['brew']}" info --cask "$cask")"
        str="$(koopa_extract_version "$str")"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}
