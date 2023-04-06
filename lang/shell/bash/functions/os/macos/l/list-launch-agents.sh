#!/usr/bin/env bash

koopa_macos_list_launch_agents() {
    # """
    # List launch agents.
    # @note Updated 2022-02-16.
    # """
    local -A app
    koopa_assert_has_no_args "$#"
    app['ls']="$(koopa_locate_ls)"
    koopa_assert_is_executable "${app[@]}"
    "${app['ls']}" \
        --ignore='disabled' \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}
