#!/usr/bin/env bash

# NOTE How to automate this step?
# Disable sleep when screen is off while plugged in:
# Displays > Advanced > Prevent automatic sleeping on power adapter when the
# display is off

main() {
    # """
    # Configure macOS system preferences.
    # @note Updated 2024-12-15.
    #
    # """
    local -A app
    # > app['scutil']="$(koopa_macos_locate_scutil)"
    # > app['systemsetup']="$(koopa_macos_locate_systemsetup)"
    app['chflags']="$(koopa_macos_locate_chflags)"
    app['defaults']="$(koopa_macos_locate_defaults)"
    app['kill_all']="$(koopa_macos_locate_kill_all)"
    app['mdutil']="$(koopa_macos_locate_mdutil)"
    app['nvram']="$(koopa_macos_locate_nvram)"
    app['pmset']="$(koopa_macos_locate_pmset)"
    app['tmutil']="$(koopa_macos_locate_tmutil)"
    koopa_assert_is_executable "${app[@]}"
    koopa_h2 'Startup and Lock Screen'
    # For reference, here's how to set computer name from the command line.
    # > local comp_name
    # > koopa_sudo "${app['scutil']}" --set ComputerName "$comp_name"
    # > koopa_sudo "${app['scutil']}" --set HostName "$comp_name"
    # > koopa_sudo "${app['scutil']}" --set LocalHostName "$comp_name"
    # > koopa_sudo "${app['defaults']}" write \
    # >     /Library/Preferences/SystemConfiguration/com.apple.smb.server \
    # >     NetBIOSName -string "$comp_name"
    koopa_alert 'Disabling startup chime on boot.'
    # Can reenable with: 'sudo nvram -d SystemAudioVolume'.
    # Alternative disables: '%80', '%01', '%00'.
    koopa_sudo "${app['nvram']}" SystemAudioVolume=' '
    # Can use this approach for Macs from 2016-2020.
    # https://www.howtogeek.com/260693/
    #   how-to-disable-the-boot-sound-or-startup-chime-on-a-mac/
    # > koopa_sudo "${app['nvram']}" StartupMute='%00'
    # NOTE This doesn't appear to work in 12.5+, so disabling.
    # Reveal IP address, hostname, OS version, etc. when clicking the clock
    # in the login window.
    # > koopa_alert 'Enabling admin mode for lock screen (click on the clock).'
    # > koopa_sudo "${app['defaults']}" write \
    # >     '/Library/Preferences/com.apple.loginwindow' \
    # >     'AdminHostInfo'\
    # >     'HostName'
    koopa_h2 'Locale'
    # Set the timezone.
    # See 'sudo systemsetup -listtimezones' for other values.
    # > koopa_sudo "${app['systemsetup']}" \
    # >     -settimezone 'America/New_York' \
    # >     > /dev/null
    koopa_alert 'Enabling language input in menu bar.'
    koopa_sudo "${app['defaults']}" write \
        '/Library/Preferences/com.apple.loginwindow' \
        'showInputMenu' \
        -bool true
    koopa_h2 'Power management'
    koopa_alert 'Configuring power management.'
    # How to restore power management defaults.
    # > "${app['pmset']}" -c 2 -b 1 -u 1
    # Sleep the display after 15 minutes when connected to power.
    koopa_sudo "${app['pmset']}" -c 'displaysleep' 15
    # Check current settings.
    "${app['pmset']}" -g
    # > koopa_h2 'Screen'
    # Enable HiDPI display modes (requires restart).
    # > koopa_sudo "${app['defaults']}" write \
    # >     '/Library/Preferences/com.apple.windowserver' \
    # >     'DisplayResolutionEnabled' \
    # >     -bool true
    koopa_h2 'Finder'
    koopa_alert "Enabling visibility of '/Volumes' in Finder."
    koopa_sudo "${app['chflags']}" nohidden '/Volumes'
    koopa_h2 'Spotlight'
    koopa_alert 'Enabling Spotlight indexing for main volume.'
    koopa_sudo "${app['mdutil']}" -i on '/'
    # For reference, how to rebuild the index from scratch:
    # Load new settings before rebuilding the index.
    # > "${app['killall']" 'mds' > /dev/null 2>&1
    # > koopa_sudo "${app['mdutil']}" -E '/'
    # > "${app['mdutil']}" -s '/'
    "${app['mdutil']}" -s /
    koopa_h2 'Time Machine'
    koopa_alert 'Disabling Time Machine backups.'
    koopa_sudo "${app['tmutil']}" disable
    "${app['tmutil']}" listlocalsnapshotdates '/'
    koopa_alert_note 'Some of these changes may require restart to take effect.'
    return 0
}
