#!/usr/bin/env bash

koopa_brew_version() {
    # """
    # Get the version of a Homebrew brew from JSON.
    # @note Updated 2022-09-29.
    #
    # @examples
    # > koopa_homebrew_brew_version 'coreutils' 'findutils'
    # # 9.1
    # # 4.9.0
    # """
    local app brew
    declare -A app
    koopa_assert_has_args "$#"
    app['brew']="$(koopa_locate_brew)"
    app['jq']="$(koopa_locate_jq)"
    [[ -x "${app['brew']}" ]] || exit 1
    [[ -x "${app['jq']}" ]] || exit 1
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
