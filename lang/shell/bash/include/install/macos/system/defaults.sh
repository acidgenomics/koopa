#!/usr/bin/env bash

# FIXME Tell the user what we're doing here more clearly.

main() {
    # """
    # Install macOS system defaults.
    # @note Updated 2022-09-02.
    #
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['chflags']="$(koopa_macos_locate_chflags)"
        ['defaults']="$(koopa_macos_locate_defaults)"
        ['kill_all']="$(koopa_macos_locate_kill_all)"
        ['mdutil']="$(koopa_macos_locate_mdutil)"
        ['nvram']="$(koopa_macos_locate_nvram)"
        ['pmset']="$(koopa_macos_locate_pmset)"
        # > ['scutil']="$(koopa_macos_locate_scutil)"
        ['sudo']="$(koopa_locate_sudo)"
        # > ['systemsetup']="$(koopa_macos_locate_systemsetup)"
        ['tmutil']="$(koopa_macos_locate_tmutil)"
    )
    [[ -x "${app['chflags']}" ]] || return 1
    [[ -x "${app['defaults']}" ]] || return 1
    [[ -x "${app['kill_all']}" ]] || return 1
    [[ -x "${app['mdutil']}" ]] || return 1
    [[ -x "${app['nvram']}" ]] || return 1
    [[ -x "${app['pmset']}" ]] || return 1
    # > [[ -x "${app['scutil']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    # > [[ -x "${app['systemsetup']}" ]] || return 1
    [[ -x "${app['tmutil']}" ]] || return 1
    # Startup and Lock Screen
    # --------------------------------------------------------------------------
    # For reference, here's how to set computer name from the command line.
    # > local comp_name
    # > "${app['sudo']}" "${app['scutil']}" --set ComputerName "$comp_name"
    # > "${app['sudo']}" "${app['scutil']}" --set HostName "$comp_name"
    # > "${app['sudo']}" "${app['scutil']}" --set LocalHostName "$comp_name"
    # > "${app['sudo']}" "${app['defaults']}" write \
    # >     /Library/Preferences/SystemConfiguration/com.apple.smb.server \
    # >     NetBIOSName -string "$comp_name"
    koopa_alert 'Disabling startup chime on boot.'
    "${app['sudo']}" "${app['nvram']}" SystemAudioVolume=' '
    # NOTE This doesn't appear to work in 12.5+, so disabling.
    # Reveal IP address, hostname, OS version, etc. when clicking the clock
    # in the login window.
    # > koopa_alert 'Enabling admin mode for lock screen (click on the clock).'
    # > "${app['sudo']}" "${app['defaults']}" write \
    # >     '/Library/Preferences/com.apple.loginwindow' \
    # >     'AdminHostInfo'\
    # >     'HostName'
    # Locale
    # --------------------------------------------------------------------------
    # Set the timezone.
    # See 'sudo systemsetup -listtimezones' for other values.
    # > "${app['sudo']}" "${app['systemsetup']}" \
    # >     -settimezone 'America/New_York' \
    # >     > /dev/null
    # Show language menu in the top right corner of the boot screen.
    # > "${app['sudo']}" "${app['defaults']}" write \
    # >     '/Library/Preferences/com.apple.loginwindow' \
    # >     'showInputMenu' \
    # >     -bool true
    # Power management
    # --------------------------------------------------------------------------
    koopa_alert 'Configuring power management.'
    # How to restore power management defaults.
    # > "${app['pmset']}" -c 2 -b 1 -u 1
    # Sleep the display after 15 minutes when connected to power.
    "${app['sudo']}" "${app['pmset']}" -c 'displaysleep' 15
    # Check current settings.
    "${app['pmset']}" -g
    # Screen
    # --------------------------------------------------------------------------
    # Enable HiDPI display modes (requires restart).
    # > "${app['sudo']}" "${app['defaults']}" write \
    # >     '/Library/Preferences/com.apple.windowserver' \
    # >     'DisplayResolutionEnabled' \
    # >     -bool true
    # Finder
    # --------------------------------------------------------------------------
    koopa_alert "Enabling visibility of '/Volumes' in Finder."
    "${app['sudo']}" "${app['chflags']}" nohidden '/Volumes'
    # Spotlight
    # --------------------------------------------------------------------------
    koopa_alert 'Disabling Spotlight.'
    # Load new settings before rebuilding the index.
    # > "${app['killall']" 'mds' > /dev/null 2>&1
    # Ensure indexing is disabled for the main volume.
    "${app['sudo']}" "${app['mdutil']}" -i off '/'
    # For reference, how to rebuild the index from scratch.
    # > "${app['sudo']}" "${app['mdutil']}" -E '/'
    # > "${app['mdutil']}" -s '/'
    # Hide Spotlight tray-icon (and subsequent helper).
    # > koopa_chmod --sudo '0600' \
    # >     '/System/Library/CoreServices/Search.bundle/Contents/MacOS/Search'
    # Time Machine
    # --------------------------------------------------------------------------
    koopa_alert 'Disabling Time Machine backups.'
    "${app['sudo']}" "${app['tmutil']}" disable
    "${app['tmutil']}" listlocalsnapshotdates '/'
    koopa_alert_note 'Some of these changes require logout to take effect.'
    return 0
}
