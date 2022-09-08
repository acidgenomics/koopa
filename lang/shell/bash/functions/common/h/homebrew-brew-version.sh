#!/usr/bin/env bash

koopa_homebrew_brew_version() {
    # """
    # Get the version of a Homebrew brew from JSON.
    # @note Updated 2022-09-08.
    #
    # @examples
    # > koopa_homebrew_brew_version 'coreutils' 'findutils'
    # # 9.1
    # # 4.9.0
    # """
    local app brew
    koopa_assert_has_args "$#"
    declare -A app=(
        ['brew']="$(koopa_locate_brew)"
        ['jq']="$(koopa_locate_jq)"
    )
    [[ -x "${app['brew']}" ]] || return 1
    [[ -x "${app['jq']}" ]] || return 1
    for brew in "$@"
    do
        local str
        str="$( \
            "${app['brew']}" info --json "$brew" \
                | "${app['jq']}" --raw-output '.[].versions.stable'
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}
