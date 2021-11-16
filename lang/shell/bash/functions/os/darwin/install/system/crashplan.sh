#!/usr/bin/env bash

# FIXME Need to support this in koopa autocompletion.
# FIXME Need to inform user when CrashPlan isn't installed.
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
# FIXME Need to inform user when CrashPlan isn't installed.
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
