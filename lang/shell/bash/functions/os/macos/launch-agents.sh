#!/usr/bin/env bash

koopa::macos_list_launch_agents() { # {{{1
    # """
    # List launch agents.
    # @note Updated 2022-02-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::alert 'Listing launch agents and daemons.'
    ls \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}

# FIXME Need to standardize these disabler/enabler functions for macOS.

koopa::macos_disable_crashplan() { # {{{1
    # """
    # Disable CrashPlan.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [launchctl]="$(koopa::macos_locate_launchctl)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [system_plist]='/Library/LaunchDaemons/com.crashplan.engine.plist'
        [user_plist]="${HOME:?}/Library/LaunchAgents/com.crashplan.engine.plist"
    )
    if [[ -f "${dict[system_plist]}" ]]
    then
        # > "${app[sudo]}" "${app[launchctl]}" stop 'com.crashplan.engine'
        "${app[sudo]}" "${app[launchctl]}" unload "${dict[system_plist]}"
        koopa::mv --sudo \
            "${dict[system_plist]}" \
            "${dict[system_plist]}.disabled"
    fi
    if [[ -f "${dict[user_plist]}" ]]
    then
        "${app[launchctl]}" unload "${dict[user_plist]}"
        koopa::mv \
            "${dict[user_plist]}" \
            "${dict[user_plist]}.disabled"
    fi
    return 0
}

# FIXME Need to support this in koopa autocompletion.
koopa::macos_disable_microsoft_teams_updater() { # {[[1
    # """
    # Disable the Microsoft Teams updater that runs in the background.
    # @note Updated 2021-10-29.
    # """
    local name_fancy plist_file prefix
    koopa::assert_has_no_args "$#"
    name_fancy='Microsoft Teams'
    prefix='/Library/LaunchDaemons'
    plist_file="${prefix}/com.microsoft.teams.TeamsUpdaterDaemon.plist"
    if [[ ! -f "$plist_file" ]]
    then
        koopa::stop "${name_fancy} is not enabled at '${plist_file}'."
    fi
    koopa::alert "Disabling ${name_fancy} updater."
    koopa::mv --sudo --target-directory="${prefix}/disabled" "$plist_file"
    return 0
}

# FIXME Need to add corresponding enabler function for Microsoft Teams.

koopa::macos_enable_crashplan() {  # {{{1
    # """
    # Enable CrashPlan.
    # @note Updated 2021-11-16.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [launchctl]="$(koopa::macos_locate_launchctl)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [system_plist]='/Library/LaunchDaemons/com.crashplan.engine.plist'
        [user_plist]="${HOME}/Library/LaunchAgents/com.crashplan.engine.plist"
    )
    if [[ -f "${dict[system_plist]}.disabled" ]]
    then
        koopa::mv --sudo \
            "${dict[system_plist]}.disabled" \
            "${dict[system_plist]}"
    fi
    if [[ -f "${dict[system_plist]}" ]]
    then
        "${app[sudo]}" "${app[launchctl]}" load "$system_plist"
        # > "${app[sudo]}" "${app[launchctl]}" start 'com.crashplan.engine'
    fi
    if [[ -f "${dict[user_plist]}.disabled" ]]
    then
        koopa::mv \
            "${dict[user_plist]}.disabled" \
            "${dict[user_plist]}"
    fi
    if [[ -f "${dict[user_plist]}" ]]
    then
        "${app[launchctl]}" load "${dict[user_plist]}"
    fi
    return 0
}
