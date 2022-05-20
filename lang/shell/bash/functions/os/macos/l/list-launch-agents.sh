#!/usr/bin/env bash

koopa_macos_list_launch_agents() {
    # """
    # List launch agents.
    # @note Updated 2022-02-16.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [ls]="$(koopa_locate_ls)"
    )
    koopa_alert 'Listing launch agents and daemons.'
    "${app[ls]}" \
        --ignore='disabled' \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}
