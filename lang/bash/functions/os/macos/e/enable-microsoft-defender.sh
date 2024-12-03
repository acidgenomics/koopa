#!/usr/bin/env bash

koopa_macos_enable_microsoft_defender() {
    # """
    # Enable Microsoft Defender.
    # @note Updated 2024-12-03.
    # """
    local -A app
    local -a plist_files
    koopa_assert_has_no_args "$#"
    app['systemextensionsctl']="$(koopa_macos_locate_systemextensionsctl)"
    koopa_assert_is_executable "${app[@]}"
    plist_files=(
        '/Library/LaunchAgents/com.microsoft.dlp.agent.plist'
        '/Library/LaunchAgents/com.microsoft.wdav.tray.plist'
        '/Library/LaunchDaemons/com.microsoft.dlp.daemon.plist'
        '/Library/LaunchDaemons/com.microsoft.fresno.plist'
        '/Library/LaunchDaemons/com.microsoft.fresno.uninstall.plist'
    )
    koopa_macos_enable_plist_file "${plist_files[@]}"
    "${app['systemextensionsctl']}" list
    return 0
}
