#!/usr/bin/env bash

koopa_macos_disable_crashplan() {
    # """
    # Disable CrashPlan.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.crashplan.engine.plist" \
        '/Library/LaunchDaemons/com.crashplan.engine.plist'
    return 0
}

koopa_macos_disable_google_keystone() {
    # """
    # Disable Google Keystone.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchAgents/com.google.keystone.agent.plist' \
        '/Library/LaunchAgents/com.google.keystone.xpcservice.plist' \
        '/Library/LaunchDaemons/com.google.keystone.daemon.plist'
    return 0
}

koopa_macos_disable_gpg_updater() {
    # """
    # Disable GPG tools updater.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}

koopa_macos_disable_microsoft_teams_updater() { # {[[1
    # """
    # Disable Microsoft Teams updater.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchDaemons/com.microsoft.teams.TeamsUpdaterDaemon.plist'
    return 0
}

koopa_macos_disable_plist_file() {
    # """
    # Disable a plist file correponding to a launch agent or daemon.
    # @note Updated 2022-02-16.
    # """
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [launchctl]="$(koopa_macos_locate_launchctl)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        local dict
        declare -A dict=(
            [daemon]=0
            [enabled_file]="$file"
            [sudo]=1
        )
        dict[disabled_file]="$(koopa_dirname "${dict[enabled_file]}")/\
disabled/$(koopa_basename "${dict[enabled_file]}")"
        koopa_alert "Disabling '${dict[enabled_file]}'."
        if koopa_str_detect_fixed \
            --string="${dict[enabled_file]}" \
            --pattern='/LaunchDaemons/'
        then
            dict[daemon]=1
        fi
        if koopa_str_detect_regex \
            --string="${dict[enabled_file]}" \
            --pattern="^${HOME:?}"
        then
            dict[sudo]=0
        fi
        case "${dict[sudo]}" in
            '0')
                if [[ "${dict[daemon]}" -eq 1 ]]
                then
                    "${app[launchctl]}" \
                        unload "${dict[enabled_file]}"
                fi
                koopa_mv \
                    "${dict[enabled_file]}" \
                    "${dict[disabled_file]}"
                ;;
            '1')
                if [[ "${dict[daemon]}" -eq 1 ]]
                then
                    "${app[sudo]}" "${app[launchctl]}" \
                        unload "${dict[enabled_file]}"
                fi
                koopa_mv --sudo \
                    "${dict[enabled_file]}" \
                    "${dict[disabled_file]}"
                ;;
        esac
    done
    return 0
}

koopa_macos_disable_privileged_helper_tool() {
    # """
    # Disable a privileged helper tool.
    # @note Updated 2022-02-16.
    # """
    local bn dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    for bn in "$@"
    do
        local dict
        declare -A dict=(
            [enabled_file]="/Library/PrivilegedHelperTools/${bn}"
        )
        dict[disabled_file]="$(koopa_dirname "${dict[enabled_file]}")/\
disabled/$(koopa_basename "${dict[enabled_file]}")"
        koopa_assert_is_file "${dict[enabled_file]}"
        koopa_assert_is_not_file "${dict[disabled_file]}"
        koopa_alert "Disabling '${dict[disabled_file]}'."
        koopa_mv --sudo "${dict[enabled_file]}" "${dict[disabled_file]}"
    done
    return 0
}

koopa_macos_disable_zoom_daemon() {
    # """
    # Disable Zoom daemon.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist'
    koopa_macos_disable_privileged_helper_tool \
        'us.zoom.ZoomDaemon'
}

koopa_macos_enable_crashplan() {  # {{{1
    # """
    # Enable CrashPlan.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.crashplan.engine.plist" \
        '/Library/LaunchDaemons/com.crashplan.engine.plist'
    return 0
}

koopa_macos_enable_google_keystone() {
    # """
    # Enable Google Keystone.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/com.google.keystone.agent.plist' \
        '/Library/LaunchAgents/com.google.keystone.xpcservice.plist' \
        '/Library/LaunchDaemons/com.google.keystone.daemon.plist'
    return 0
}

koopa_macos_enable_gpg_updater() {
    # """
    # Enable GPG tools updater.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}

koopa_macos_enable_microsoft_teams_updater() { # {[[1
    # """
    # Enable Microsoft Teams updater.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchDaemons/com.microsoft.teams.TeamsUpdaterDaemon.plist'
    return 0
}

koopa_macos_enable_plist_file() {
    # """
    # Enable a disabled plist file correponding to a launch agent or daemon.
    # @note Updated 2022-02-16.
    # """
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [launchctl]="$(koopa_macos_locate_launchctl)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_assert_is_not_file "$@"
    for file in "$@"
    do
        local dict
        declare -A dict=(
            [daemon]=0
            [enabled_file]="$file"
            [sudo]=1
        )
        dict[disabled_file]="$(koopa_dirname "${dict[enabled_file]}")/\
disabled/$(koopa_basename "${dict[enabled_file]}")"
        koopa_alert "Enabling '${dict[enabled_file]}'."
        if koopa_str_detect_fixed \
            --string="${dict[enabled_file]}" \
            --pattern='/LaunchDaemons/'
        then
            dict[daemon]=1
        fi
        if koopa_str_detect_regex \
            --string="${dict[enabled_file]}" \
            --pattern="^${HOME:?}"
        then
            dict[sudo]=0
        fi
        case "${dict[sudo]}" in
            '0')
                koopa_mv \
                    "${dict[disabled_file]}" \
                    "${dict[enabled_file]}"
                if [[ "${dict[daemon]}" -eq 1 ]]
                then
                    "${app[launchctl]}" \
                        load "${dict[enabled_file]}"
                fi
                ;;
            '1')
                koopa_mv --sudo \
                    "${dict[disabled_file]}" \
                    "${dict[enabled_file]}"
                if [[ "${dict[daemon]}" -eq 1 ]]
                then
                    "${app[sudo]}" "${app[launchctl]}" \
                        load "${dict[enabled_file]}"
                fi
                ;;
        esac
    done
    return 0
}

koopa_macos_enable_privileged_helper_tool() {
    # """
    # Enable a privileged helper tool.
    # @note Updated 2022-02-16.
    # """
    local bn dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    for bn in "$@"
    do
        local dict
        declare -A dict=(
            [enabled_file]="/Library/PrivilegedHelperTools/${bn}"
        )
        dict[disabled_file]="$(koopa_dirname "${dict[enabled_file]}")/\
disabled/$(koopa_basename "${dict[enabled_file]}")"
        koopa_assert_is_not_file "${dict[enabled_file]}"
        koopa_assert_is_file "${dict[disabled_file]}"
        koopa_alert "Enabling '${dict[disabled_file]}'."
        koopa_mv --sudo "${dict[disabled_file]}" "${dict[enabled_file]}"
    done
    return 0
}

koopa_macos_enable_zoom_daemon() {
    # """
    # Enable Zoom daemon.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist'
    koopa_macos_enable_privileged_helper_tool \
        'us.zoom.ZoomDaemon'
}

koopa_macos_list_launch_agents() {
    # """
    # List launch agents.
    # @note Updated 2022-02-16.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [ls]="$(koopa_locate_ls)"
    )
    koopa_alert 'Listing launch agents and daemons.'
    "${app[ls]}" \
        --ignore='disabled' \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}
