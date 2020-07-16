#!/usr/bin/env bash

koopa::macos_list_launch_agents() {
    koopa::assert_has_no_args "$#"
    koopa::h1 'Listing launch agents and daemons.'
    ls \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}

