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
    # > app['scutil']="$(_koopa_macos_locate_scutil)"
    # > app['systemsetup']="$(_koopa_macos_locate_systemsetup)"
    app['chflags']="$(_koopa_macos_locate_chflags)"
    app['defaults']="$(_koopa_macos_locate_defaults)"
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    app['mdutil']="$(_koopa_macos_locate_mdutil)"
    app['nvram']="$(_koopa_macos_locate_nvram)"
    app['pmset']="$(_koopa_macos_locate_pmset)"
    app['tmutil']="$(_koopa_macos_locate_tmutil)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo_trigger
    _koopa_h2 'Startup and Lock Screen'
    # For reference, here's how to set computer name from the command line.
    # > local comp_name
    # > _koopa_sudo "${app['scutil']}" --set ComputerName "$comp_name"
    # > _koopa_sudo "${app['scutil']}" --set HostName "$comp_name"
    # > _koopa_sudo "${app['scutil']}" --set LocalHostName "$comp_name"
    # > _koopa_sudo "${app['defaults']}" write \
    # >     /Library/Preferences/SystemConfiguration/com.apple.smb.server \
    # >     NetBIOSName -string "$comp_name"
    _koopa_alert 'Disabling startup chime on boot.'
    # Can reenable with: 'sudo nvram -d SystemAudioVolume'.
    # Alternative disables: '%80', '%01', '%00'.
    _koopa_sudo "${app['nvram']}" SystemAudioVolume=' '
    # Can use this approach for Macs from 2016-2020.
    # https://www.howtogeek.com/260693/
    #   how-to-disable-the-boot-sound-or-startup-chime-on-a-mac/
    # > _koopa_sudo "${app['nvram']}" StartupMute='%00'
    # NOTE This doesn't appear to work in 12.5+, so disabling.
    # Reveal IP address, hostname, OS version, etc. when clicking the clock
    # in the login window.
    # > _koopa_alert 'Enabling admin mode for lock screen (click on the clock).'
    # > _koopa_sudo "${app['defaults']}" write \
    # >     '/Library/Preferences/com.apple.loginwindow' \
    # >     'AdminHostInfo'\
    # >     'HostName'
    _koopa_h2 'Locale'
    # Set the timezone.
    # See 'sudo systemsetup -listtimezones' for other values.
    # > _koopa_sudo "${app['systemsetup']}" \
    # >     -settimezone 'America/New_York' \
    # >     > /dev/null
    _koopa_alert 'Enabling language input in menu bar.'
    _koopa_sudo "${app['defaults']}" write \
        '/Library/Preferences/com.apple.loginwindow' \
        'showInputMenu' \
        -bool true
    _koopa_h2 'Power management'
    _koopa_alert 'Configuring power management.'
    # How to restore power management defaults.
    # > "${app['pmset']}" -c 2 -b 1 -u 1
    # Sleep the display after 15 minutes when connected to power.
    _koopa_sudo "${app['pmset']}" -c 'displaysleep' 15
    # Check current settings.
    "${app['pmset']}" -g
    # > _koopa_h2 'Screen'
    # Enable HiDPI display modes (requires restart).
    # > _koopa_sudo "${app['defaults']}" write \
    # >     '/Library/Preferences/com.apple.windowserver' \
    # >     'DisplayResolutionEnabled' \
    # >     -bool true
    _koopa_h2 'Finder'
    _koopa_alert "Enabling visibility of '/Volumes' in Finder."
    _koopa_sudo "${app['chflags']}" nohidden '/Volumes'
    _koopa_h2 'Spotlight'
    _koopa_alert 'Enabling Spotlight indexing for main volume.'
    _koopa_sudo "${app['mdutil']}" -i on '/'
    # For reference, how to rebuild the index from scratch:
    # Load new settings before rebuilding the index.
    # > "${app['killall']" 'mds' > /dev/null 2>&1
    # > _koopa_sudo "${app['mdutil']}" -E '/'
    # > "${app['mdutil']}" -s '/'
    "${app['mdutil']}" -s /
    _koopa_h2 'Time Machine'
    _koopa_alert 'Disabling Time Machine backups.'
    _koopa_sudo "${app['tmutil']}" disable
    "${app['tmutil']}" listlocalsnapshotdates '/'
    _koopa_alert_note 'Some of these changes may require restart to take effect.'
    return 0
}
