#!/usr/bin/env bash

_koopa_brew_version() {
    # """
    # Get the version of a Homebrew brew from JSON.
    # @note Updated 2022-09-29.
    #
    # @examples
    # > _koopa_homebrew_brew_version 'coreutils' 'findutils'
    # # 9.1
    # # 4.9.0
    # """
    local -A app
    local brew
    _koopa_assert_has_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    app['jq']="$(_koopa_locate_jq)"
    _koopa_assert_is_executable "${app[@]}"
    for brew in "$@"
    do
        local str
        str="$( \
            "${app['brew']}" info --json "$brew" \
                | "${app['jq']}" --raw-output '.[].versions.stable'
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}
