#!/usr/bin/env bash

koopa_node_package_version() {
    # """
    # Node (NPM) package version.
    # @note Updated 2022-03-21.
    #
    # @seealso
    # - https://stackoverflow.com/questions/10972176/
    #
    # @examples
    # > koopa_node_package_version 'npm'
    # """
    local app pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [jq]="$(koopa_locate_jq)"
        [npm]="$(koopa_locate_npm)"
    )
    for pkg in "$@"
    do
        local dict
        declare -A dict
        dict[pkg]="$pkg"
        dict[str]="$( \
            "${app[npm]}" --global --json list "${dict[pkg]}" \
            | "${app[jq]}" \
                --raw-output \
                ".dependencies.${dict[pkg]}.version" \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}
