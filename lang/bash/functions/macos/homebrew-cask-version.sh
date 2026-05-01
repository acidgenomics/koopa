#!/usr/bin/env bash

_koopa_macos_homebrew_cask_version() {
    # """
    # Get Homebrew Cask version.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_macos_homebrew_cask_version 'gpg-suite'
    # # 2019.2
    # """
    local -A app
    local cask
    _koopa_assert_has_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    for cask in "$@"
    do
        local str
        str="$("${app['brew']}" info --cask "$cask")"
        str="$(_koopa_extract_version "$str")"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}
