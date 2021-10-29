#!/usr/bin/env bash

# FIXME Need to harden sudo and launchctl here.

koopa::macos_disable_crashplan() { # {{{1
    # """
    # Disable CrashPlan.
    # @note Updated 2021-10-29.
    # """
    local system_plist user_plist
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    system_plist='/Library/LaunchDaemons/com.crashplan.engine.plist'
    user_plist="${HOME}/Library/LaunchAgents/com.crashplan.engine.plist"
    if [[ -f "$user_plist" ]]
    then
        launchctl unload "$user_plist"
        koopa::mv "$user_plist" "${user_plist}.disabled"
    fi
    if [[ -f "$system_plist" ]]
    then
        # > sudo launchctl stop com.crashplan.engine
        sudo launchctl unload "$system_plist"
        koopa::mv --sudo "$system_plist" "${system_plist}.disabled"
    fi
    return 0
}

koopa::macos_enable_crashplan() {  # {{{1
    # """
    # Enable CrashPlan.
    # @note Updated 2021-10-29.
    # """
    local system_plist user_plist
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    system_plist='/Library/LaunchDaemons/com.crashplan.engine.plist'
    user_plist="${HOME}/Library/LaunchAgents/com.crashplan.engine.plist"
    if [[ -f "${user_plist}.disabled" ]]
    then
        koopa::mv "${user_plist}.disabled" "$user_plist"
    fi
    if [[ -f "$user_plist" ]]
    then
        launchctl load "$user_plist"
    fi
    if [[ -f "${system_plist}.disabled" ]]
    then
        koopa::mv --sudo "${system_plist}.disabled" "$system_plist"
    fi
    if [[ -f "$system_plist" ]]
    then
        sudo launchctl load "$system_plist"
        # > sudo launchctl start com.crashplan.engine
    fi
    return 0
}
