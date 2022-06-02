#!/usr/bin/env bash

koopa_macos_disable_spotlight_indexing() {
    # """
    # Disable spotlight indexing.
    # @note Updated 2022-06-02.
    #
    # Conversely, use 'on' instead of 'off' to re-enable.
    #
    # Useful command to monitor mds usage:
    # > sudo fs_usage -w -f filesys mds
    # """
    local app
    declare -A app=(
        [mdutil]="$(koopa_macos_locate_mdutil)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[mdutil]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    "${app[sudo]}" "${app[mdutil]}" -a -i off
    "${app[mdutil]}" -a -s
    return 0
}
