#!/usr/bin/env bash

koopa::macos_disable_crashplan() {
    system_plist="/Library/LaunchDaemons/com.crashplan.engine.plist"
    user_plist="${HOME}/Library/LaunchAgents/com.crashplan.engine.plist"
    if [[ -f "$user_plist" ]]
    then
        launchctl unload "$user_plist"
        mv -v "$user_plist" "${user_plist}.disabled"
    fi
    if [[ -f "$system_plist" ]]
    then
        # > sudo launchctl stop com.crashplan.engine
        sudo launchctl unload "$system_plist"
        sudo mv -v "$system_plist" "${system_plist}.disabled"
    fi
    return 0
}
