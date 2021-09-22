#!/usr/bin/env bash

koopa::macos_disable_microsoft_teams_updater() { # {[[1
    # """
    # Disable the Microsoft Teams updater that runs in the background.
    # @note Updated 2021-09-22.
    # """
    local plist prefix
    plist='com.microsoft.teams.TeamsUpdaterDaemon.plist'
    prefix='/Library/LaunchDaemons'
    [[ -f "${prefix}/${plist}" ]] || return 0
    koopa::alert 'Disabling Microsoft Teams updater.'
    koopa::mv --sudo \
        --target="${prefix}/disabled" \
        "${prefix}/${plist}"
    return 0
}

