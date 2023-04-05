#!/usr/bin/env bash

# FIXME How to set disable sleep when screen is off while plugged in:
# Displays > Advanced > Prevent automatic sleeping on power adapter when the
# display is off

main() {
    # """
    # Install macOS system defaults.
    # @note Updated 2022-09-02.
    #
    # """
    local app
    local -A app
    koopa_assert_has_no_args "$#"
    # > app['scutil']="$(koopa_macos_locate_scutil)"
    # > app['systemsetup']="$(koopa_macos_locate_systemsetup)"
    app['chflags']="$(koopa_macos_locate_chflags)"
    app['defaults']="$(koopa_macos_locate_defaults)"
    app['kill_all']="$(koopa_macos_locate_kill_all)"
    app['mdutil']="$(koopa_macos_locate_mdutil)"
    app['nvram']="$(koopa_macos_locate_nvram)"
    app['pmset']="$(koopa_macos_locate_pmset)"
    app['sudo']="$(koopa_locate_sudo)"
    app['tmutil']="$(koopa_macos_locate_tmutil)"
    # > [[ -x "${app['scutil']}" ]] || exit 1
    # > [[ -x "${app['systemsetup']}" ]] || exit 1
    [[ -x "${app['chflags']}" ]] || exit 1
    [[ -x "${app['defaults']}" ]] || exit 1
    [[ -x "${app['kill_all']}" ]] || exit 1
    [[ -x "${app['mdutil']}" ]] || exit 1
    [[ -x "${app['nvram']}" ]] || exit 1
    [[ -x "${app['pmset']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    [[ -x "${app['tmutil']}" ]] || exit 1
    koopa_h2 'Startup and Lock Screen'
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
    koopa_h2 'Locale'
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
    koopa_h2 'Power management'
    koopa_alert 'Configuring power management.'
    # How to restore power management defaults.
    # > "${app['pmset']}" -c 2 -b 1 -u 1
    # Sleep the display after 15 minutes when connected to power.
    "${app['sudo']}" "${app['pmset']}" -c 'displaysleep' 15
    # Check current settings.
    "${app['pmset']}" -g
    koopa_h2 'Screen'
    # Enable HiDPI display modes (requires restart).
    # > "${app['sudo']}" "${app['defaults']}" write \
    # >     '/Library/Preferences/com.apple.windowserver' \
    # >     'DisplayResolutionEnabled' \
    # >     -bool true
    koopa_h2 'Finder'
    koopa_alert "Enabling visibility of '/Volumes' in Finder."
    "${app['sudo']}" "${app['chflags']}" nohidden '/Volumes'
    koopa_h2 'Spotlight'
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
    koopa_h2 'Time Machine'
    koopa_alert 'Disabling Time Machine backups.'
    "${app['sudo']}" "${app['tmutil']}" disable
    "${app['tmutil']}" listlocalsnapshotdates '/'
    koopa_alert_note 'Some of these changes require logout to take effect.'
    return 0
}
