#!/usr/bin/env bash

koopa_macos_disable_microsoft_defender() {
    # """
    # Disable Microsoft Defender.
    # @note Updated 2024-12-03.
    #
    # These system extensions need to be disabled:
    # - Microsoft Defender Endpoint Security Extension
    #   (com.microsoft.wdav.epsext)
    # - Microsoft Defender Network Extension
    #   (com.microsoft.wdav.netext)
    #
    # These extensions are located at:
    # /Applications/Microsoft Defender.app/Contents/Library/SystemExtensions
    #
    # @seealso
    # - https://github.com/miccal/homebrew-miccal/blob/master/
    #   Casks/m-microsoft-defender.rb
    # - https://uko.codes/killing-microsoft-defender-on-a-mac
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
    koopa_macos_disable_plist_file "${plist_files[@]}"
    "${app['systemextensionsctl']}" list
    koopa_alert_note "Reboot to disable \
Microsoft Defender Endpoint Security Extension (com.microsoft.wdav.epsext) and \
Microsoft Defender Network Extension (com.microsoft.wdav.netext)."
    return 0
}
