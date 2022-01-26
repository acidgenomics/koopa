#!/usr/bin/env bash

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

# FIXME Need to add corresponding enabler function.
