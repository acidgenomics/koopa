#!/usr/bin/env bash

koopa_macos_enable_microsoft_teams_updater() {
    # """
    # Enable Microsoft Teams updater.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchDaemons/com.microsoft.teams.TeamsUpdaterDaemon.plist'
    return 0
}
