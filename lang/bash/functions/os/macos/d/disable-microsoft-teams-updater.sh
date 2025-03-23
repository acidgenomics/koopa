#!/usr/bin/env bash

koopa_macos_disable_microsoft_teams_updater() {
    # """
    # Disable Microsoft Teams updater.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchDaemons/com.microsoft.teams.TeamsUpdaterDaemon.plist'
    return 0
}
