#!/usr/bin/env bash

koopa::macos_disable_crashplan() {
    # """
    # Disable CrashPlan.
    # @note Updated 2020-07-20.
    # """
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
        koopa::mv -S "$system_plist" "${system_plist}.disabled"
    fi
    return 0
}

koopa::macos_enable_crashplan() {  # {{{1
    # """
    # Enable CrashPlan.
    # @note Updated 2020-07-17.
    # """
    local system_plist user_plist
    system_plist='/Library/LaunchDaemons/com.crashplan.engine.plist'
    user_plist="${HOME}/Library/LaunchAgents/com.crashplan.engine.plist"
    if [[ -f "${user_plist}.disabled" ]]
    then
        mv -v "${user_plist}.disabled" "$user_plist"
    fi
    if [[ -f "$user_plist" ]]
    then
        launchctl load "$user_plist"
    fi
    if [[ -f "${system_plist}.disabled" ]]
    then
        sudo mv -v "${system_plist}.disabled" "$system_plist"
    fi
    if [[ -f "$system_plist" ]]
    then
        sudo launchctl load "$system_plist"
        # > sudo launchctl start com.crashplan.engine
    fi
    return 0
}
