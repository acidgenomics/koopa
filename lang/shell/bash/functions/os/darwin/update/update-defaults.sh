#!/usr/bin/env bash

koopa::macos_update_defaults() { # {{{1
    # """
    # Update macOS defaults.
    # @note Updated 2021-10-31.
    #
    # Tested to work on macOS Big Sur.
    #
    # How to read current value:
    # defaults read com.apple.AppleMultitouchTrackpad
    #
    # By default sets value in ~/Library/Preferences/.GlobalPreferences.plist.
    #
    # The '-currentHost' flag sets value in:
    # ~/Library/Preferences/ByHost/.GlobalPreferences.<UUID>.plist
    #
    # Where your hardware UUID can be determined with:
    # > ioreg -c IOPlatformExpertDevice  -d 2 \
    # >     | awk -F'"' '/IOPlatformUUID/ { print $(NF-1) }'
    #
    # @seealso
    # - https://en.wikipedia.org/wiki/Defaults_(software)
    # - https://www.defaults-write.com/
    # - https://github.com/mathiasbynens/dotfiles/blob/master/.macos
    # - https://github.com/kevinSuttle/macOS-Defaults
    # - http://robservatory.com/speed-up-your-mac-via-hidden-prefs/
    # - https://www.reddit.com/r/MacOS/comments/9xtg0y/
    #       switching_system_appearance_using_terminal/e9wemy8/
    # - https://johnkastler.net/2011/12/25/os-x-defaults/
    # - https://medium.com/@notrab/friendly-os-x-defaults-d7f0cc39f2b3
    # - https://apple.stackexchange.com/questions/14001/
    # - https://github.com/tech-otaku/macos-config-big-sur/blob/
    #       main/macos-config.sh
    # """
    local app app_name dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [defaults]="$(koopa::locate_defaults)"
        [kill_all]="$(koopa::locate_kill_all)"
        [lsregister]="$(koopa::locate_lsregister)"
        [nvram]="$(koopa::locate_nvram)"
        [plistbuddy]="$(koopa::locate_plistbuddy)"
        [pmset]="$(koopa::locate_pmset)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [name_fancy]='macOS defaults'
    )
    koopa::update_start "${dict[name_fancy]}"
    # General UI/UX {{{2
    # --------------------------------------------------------------------------
    # For reference, here's how to set computer name automatically.
    # > local comp_name
    # > sudo scutil --set ComputerName "$comp_name"
    # > sudo scutil --set HostName "$comp_name"
    # > sudo scutil --set LocalHostName "$comp_name"
    # > sudo defaults write \
    # >     /Library/Preferences/SystemConfiguration/com.apple.smb.server \
    # >     NetBIOSName -string "$comp_name"
    # Disable the chime on boot.
    "${app[sudo]}" "${app[nvram]}" SystemAudioVolume=' '
    # Reduce motion.
    "${app[defaults]}" write \
        'com.apple.universalaccess' \
        'reduceMotion' \
        -bool true
    # Reduce transparency. This makes the menu bar consistently dark on Big Sur
    # but will add an annoying border to the Dock. Nothing you can do about
    # that -- it's worth the trade off of avoiding a menu bar that switches to
    # light mode depending on the desktop wallpaper.
    # > defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false
    "${app[defaults]}" write \
        'com.apple.universalaccess' \
        'reduceTransparency' \
        -bool true
    # Differentiate without color.
    defaults write \
        'com.apple.universalaccess' \
        'differentiateWithoutColor' \
        -bool true
    # Enable Dark mode by default.
    # To disable, delete entry with 'defaults delete'.
    defaults write \
        -globalDomain 'AppleInterfaceStyle' \
        -string 'Dark'
    # Accent color.
    #
    # Currently seeing an issue with highlight / accent color not getting
    # set correctly on Big Sur, so don't attempt to set here.
    #
    # Big Sur now supports multicolor highlight / accents similar to the
    # behavior in iOS, so just use this by default.
    #
    # This setting defines two properties:
    #  - AppleAccentColor
    #  - AppleAquaColorVariant
    #
    # It also presets AppleHighlightColor, but this can be overriden.
    #
    # Note that AppleAquaColorVariant is always '1' except for 'Graphite', where
    # it is '6'. Note that the AccentColor 'Blue' is default (when there is no
    # entry) and has no AppleHighlightColor definition.
    #
    # AACV: AppleAquaColorVariant
    # AC: AccentColor
    #
    # | Color    | AACV | AC | AppleHighlightColor                   |
    # |----------|------|----|---------------------------------------|
    # | Red      |    1 |  0 | '1.000000 0.733333 0.721569 Red'      |
    # | Orange   |    1 |  1 | '1.000000 0.874510 0.701961 Orange'   |
    # | Yellow   |    1 |  2 | '1.000000 0.937255 0.690196 Yellow'   |
    # | Green    |    1 |  3 | '0.752941 0.964706 0.678431 Green'    |
    # | Purple   |    1 |  5 | '0.968627 0.831373 1.000000 Purple'   |
    # | Pink     |    1 |  6 | '1.000000 0.749020 0.823529 Pink'     |
    # | Blue     |    1 | NA | NA                                    |
    # | Graphite |    6 | -1 | '0.847059 0.847059 0.862745 Graphite' |
    #
    # Here we're setting accent and highlight color to Orange by default.
    # > defaults write \
    # >     -globalDomain 'AppleAquaColorVariant' \
    # >     -int 1
    # > defaults write \
    # >     -globalDomain 'AccentColor' \
    # >     -int 1
    # > defaults write \
    # >     -globalDomain 'AppleHighlightColor' \
    # >     -string '1.000000 0.874510 0.701961 Orange'
    #
    # Set sidebar icon size to medium.
    defaults write \
        'NSGlobalDomain' \
        'NSTableViewDefaultSizeMode' \
        -int 2
    # Set the default scrollbar appearance.
    # Possible values: 'WhenScrolling', 'Automatic' and 'Always'.
    defaults write \
        'NSGlobalDomain' \
        'AppleShowScrollBars' \
        -string 'Automatic'
    # Disable the over-the-top focus ring animation.
    defaults write \
        'NSGlobalDomain' \
        'NSUseAnimatedFocusRing' \
        -bool false
    # Expand save panel by default.
    defaults write \
        'NSGlobalDomain' \
        'NSNavPanelExpandedStateForSaveMode' \
        -bool true
    defaults write \
        'NSGlobalDomain' \
        'NSNavPanelExpandedStateForSaveMode2' \
        -bool true
    # Expand print panel by default.
    defaults write \
        'NSGlobalDomain' \
        'PMPrintingExpandedStateForPrint' \
        -bool true
    defaults write \
        'NSGlobalDomain' \
        'PMPrintingExpandedStateForPrint2' \
        -bool true
    # Save to disk (not to iCloud) by default.
    defaults write \
        'NSGlobalDomain' \
        'NSDocumentSaveNewDocumentsToCloud' \
        -bool false
    # Automatically quit printer app once the print jobs complete.
    defaults write \
        'com.apple.print.PrintingPrefs' \
        'Quit When Finished' \
        -bool true
    # Disable the 'Are you sure you want to open this application?' dialog.
    defaults write \
        'com.apple.LaunchServices' \
        'LSQuarantine' \
        -bool false
    # Disable resume system-wide.
    defaults write \
        'com.apple.systempreferences' \
        'NSQuitAlwaysKeepsWindows' \
        -bool false
    # Disable automatic termination of inactive apps.
    defaults write \
        'NSGlobalDomain' \
        'NSDisableAutomaticTermination' \
        -bool true
    # Set Help Viewer windows to non-floating mode.
    defaults write \
        'com.apple.helpviewer' \
        'DevMode' \
        -bool true
    # Reveal IP address, hostname, OS version, etc. when clicking the clock
    # in the login window.
    sudo defaults write \
        '/Library/Preferences/com.apple.loginwindow' \
        'AdminHostInfo'\
        'HostName'
    # Disable Notification Center and remove the menu bar icon
    # > launchctl unload -w \
    # >   '/System/Library/LaunchAgents/com.apple.notificationcenterui.plist' \
    # >   2>/dev/null
    #
    # Disable automatic capitalization as it's annoying when typing code.
    defaults write \
        'NSGlobalDomain' \
        'NSAutomaticCapitalizationEnabled' \
        -bool false
    # Disable smart dashes as they're annoying when typing code.
    defaults write \
        'NSGlobalDomain' \
        'NSAutomaticDashSubstitutionEnabled' \
        -bool false
    # Disable automatic period substitution as it's annoying when typing code.
    defaults write \
        'NSGlobalDomain' \
        'NSAutomaticPeriodSubstitutionEnabled' \
        -bool false
    # Disable smart quotes as they're annoying when typing code.
    defaults write \
        'NSGlobalDomain' \
        'NSAutomaticQuoteSubstitutionEnabled' \
        -bool false
    # Disable auto-correct.
    defaults write \
        'NSGlobalDomain' \
        'NSAutomaticSpellingCorrectionEnabled' \
        -bool false
    # Increase window resize speed for Cocoa applications.
    defaults write \
        'NSGlobalDomain' \
        'NSWindowResizeTime' \
        '.001'
    # Dock, Dashboard, and hot corners {{{2
    # --------------------------------------------------------------------------
    # Enable highlight hover effect for the grid view of a stack (Dock).
    defaults write \
        'com.apple.dock' \
        'mouse-over-hilite-stack' \
        -bool true
    # Set the icon size of Dock items to 36 pixels.
    defaults write \
        'com.apple.dock' \
        'tilesize' \
        -int 36
    # Change minimize/maximize window effect.
    defaults write \
        'com.apple.dock' \
        'mineffect' \
        -string 'scale'
    # Minimize windows into their application's icon.
    defaults write \
        'com.apple.dock' \
        'minimize-to-application' \
        -bool true
    # Disable spring loading for all Dock items.
    defaults write \
        'com.apple.dock' \
        'enable-spring-load-actions-on-all-items' \
        -bool false
    # Show indicator lights for open applications in the Dock.
    defaults write \
        'com.apple.dock' \
        'show-process-indicators' \
        -bool true
    # Don't animate opening applications from the Dock.
    defaults write \
        'com.apple.dock' \
        'launchanim' \
        -bool false
    # Speed up Mission Control animations.
    defaults write \
        'com.apple.dock' \
        'expose-animation-duration' \
        -float 0.1
    # Don't group windows by application in Mission Control.
    # (i.e. use the old Exposé behavior instead)
    defaults write \
        'com.apple.dock' \
        'expose-group-by-app' \
        -bool false
    # Disable Dashboard.
    defaults write \
        'com.apple.dashboard' \
        'mcx-disabled' \
        -bool true
    # Don't show Dashboard as a Space.
    defaults write \
        'com.apple.dock' \
        'dashboard-in-overlay' \
        -bool true
    # Don't automatically rearrange Spaces based on most recent use.
    defaults write \
        'com.apple.dock' \
        'mru-spaces' \
        -bool false
    # Remove the auto-hiding Dock delay.
    defaults write \
        'com.apple.dock' \
        'autohide-delay' \
        -float 0
    # Remove the animation when hiding/showing the Dock.
    defaults write \
        'com.apple.dock' \
        'autohide-time-modifier' \
        -float 0
    # Automatically hide and show the Dock.
    defaults write \
        'com.apple.dock' \
        'autohide' \
        -bool true
    # Make Dock icons of hidden applications translucent.
    defaults write \
        'com.apple.dock' \
        'showhidden' \
        -bool true
    # Don't show recent applications in Dock.
    defaults write \
        'com.apple.dock' \
        'show-recents' \
        -bool false
    # Disable the Launchpad gesture (pinch with thumb and three fingers).
    defaults write \
        'com.apple.dock' \
        'showLaunchpadGestureEnabled' \
        -int 0
    # Wipe all (default) app icons from the Dock.
    # This is only really useful when setting up a new Mac, or if you don't use
    # the Dock to launch apps.
    # > defaults write com.apple.dock persistent-apps -array
    #
    # Show only open applications in the Dock.
    # > defaults write com.apple.dock static-only -bool true
    #
    # Add a spacer to the left side of the Dock (where the applications are).
    # > defaults write \
    # >     'com.apple.dock' \
    # >     'persistent-apps' \
    # >     -array-add '{tile-data={}; tile-type="spacer-tile";}'
    #
    # Add a spacer to the right side of the Dock (where the Trash is).
    # > defaults write \
    # >     'com.apple.dock' \
    # >     'persistent-others' \
    # >     -array-add '{tile-data={}; tile-type="spacer-tile";}'
    #
    # Hot corners.
    # Possible values:
    #  0: no-op
    #  2: Mission Control
    #  3: Show application windows
    #  4: Desktop
    #  5: Start screen saver
    #  6: Disable screen saver
    #  7: Dashboard
    # 10: Put display to sleep
    # 11: Launchpad
    # 12: Notification Center
    # 13: Lock Screen
    #
    # Top left screen corner: None.
    defaults write \
        'com.apple.dock' \
        'wvous-tl-corner' \
        -int 0
    defaults write \
        'com.apple.dock' \
        'wvous-tl-modifier' \
        -int 0
    # Top right screen corner: None.
    defaults write \
        'com.apple.dock' \
        'wvous-tr-corner' \
        -int 0
    defaults write 'com.apple.dock' \
        'wvous-tr-modifier' \
        -int 0
    # Bottom left screen corner: Put display to sleep.
    defaults write \
        'com.apple.dock' \
        'wvous-bl-corner' \
        -int 10
    defaults write \
        'com.apple.dock' \
        'wvous-bl-modifier' \
        -int 0
    # Bottom right screen corner: None.
    defaults write \
        'com.apple.dock' \
        'wvous-br-corner' \
        -int 0
    defaults write \
        'com.apple.dock' \
        'wvous-br-modifier' \
        -int 0
    # Keyboard, mouse, trackpad, and other input {{{2
    # --------------------------------------------------------------------------
    # Tracking speed {{{3
    # --------------------------------------------------------------------------
    # Set the tracking speed.
    # The maximum speed you can access from the System Preferences is 3.0.
    # Higher values indicate faster tracking.
    # https://www.defaults-write.com/
    #     change-your-mouse-tracking-speed-in-mac-os-x/
    defaults write -g \
        'com.apple.mouse.scaling' \
        2.0
    defaults write -g \
        'com.apple.trackpad.scaling' \
        2.0
    # Read the current tracking speed.
    # > defaults read -g 'com.apple.mouse.scaling'
    # > defaults read -g 'com.apple.trackpad.scaling'
    # Restore to default tracking speed.
    # > defaults delete -g 'com.apple.mouse.scaling'
    # > defaults delete -g 'com.apple.trackpad.scaling'
    # Multi-touch trackpad {{{3
    # --------------------------------------------------------------------------
    # Read current settings.
    # > defaults read 'com.apple.AppleMultitouchTrackpad'
    # > defaults read 'com.apple.driver.AppleBluetoothMultitouch.trackpad'
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'ActuateDetents' \
        -int 0  # 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'ActuationStrength' \
        -int 0
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'Clicking' \
        -int 1  # 0
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'DragLock' \
        -int 0
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'Dragging' \
        -int 0
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'FirstClickThreshold' \
        -int 0  # 1 (medium)
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'ForceSuppressed' \
        -int 1  # 0
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'SecondClickThreshold' \
        -int 0  # 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadCornerSecondaryClick' \
        -int 0
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadFiveFingerPinchGesture' \
        -int 2
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadFourFingerHorizSwipeGesture' \
        -int 2
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadFourFingerPinchGesture' \
        -int 2
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadFourFingerVertSwipeGesture' \
        -int 2
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadHandResting' \
        -int 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadHorizScroll' \
        -int 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadMomentumScroll' \
        -int 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadPinch' \
        -int 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadRightClick' \
        -int 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadRotate' \
        -int 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadScroll' \
        -int 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadThreeFingerDrag' \
        -int 1  # 0
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadThreeFingerHorizSwipeGesture' \
        -int 0  # 2
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadThreeFingerTapGesture' \
        -int 0
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadThreeFingerVertSwipeGesture' \
        -int 0  # 2
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadTwoFingerDoubleTapGesture' \
        -int 1
    defaults write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadTwoFingerFromRightEdgeSwipeGesture' \
        -int 3
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'Clicking' \
        -int 1  # 0
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'DragLock' \
        -int 0
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'Dragging' \
        -int 0
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadCornerSecondaryClick' \
        -int 2  # 0
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadFiveFingerPinchGesture' \
        -int 2
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadFourFingerHorizSwipeGesture' \
        -int 2
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadFourFingerPinchGesture' \
        -int 2
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadFourFingerVertSwipeGesture' \
        -int 2
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadHandResting' \
        -int 1
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadHorizScroll' \
        -int 1
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadMomentumScroll' \
        -int 1
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadPinch' \
        -int 1
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadRightClick' \
        -int 1
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadRotate' \
        -int 1
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadScroll' \
        -int 1
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerDrag' \
        -int 0
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerDrag' \
        -int 1  # 0
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerHorizSwipeGesture' \
        -int 2
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerTapGesture' \
        -int 0
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerVertSwipeGesture' \
        -int 2
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadTwoFingerDoubleTapGesture' \
        -int 1
    defaults write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadTwoFingerFromRightEdgeSwipeGesture' \
        -int 3
    # Disable look up and data detectors.
    defaults -currentHost write -g \
        'com.apple.trackpad.threeFingerTapGesture' \
        -int 0
    # Enable secondary click.
    defaults -currentHost write NSGlobalDomain \
        'com.apple.trackpad.enableSecondaryClick' \
        -bool true
    # Enable tap to click for this user and for the login screen.
    defaults -currentHost write NSGlobalDomain \
        'com.apple.mouse.tapBehavior' \
        -int 1
    defaults write NSGlobalDomain \
        'com.apple.mouse.tapBehavior' \
        -int 1
    # Map bottom right corner to right-click.
    defaults -currentHost write NSGlobalDomain \
        'com.apple.trackpad.trackpadCornerClickBehavior' \
        -int 1
    # Enable natural scroll direction.
    defaults write NSGlobalDomain \
        'com.apple.swipescrolldirection' \
        -bool true
    # Enable full keyboard access for all controls (e.g. Tab in modal dialogs).
    defaults write \
        'NSGlobalDomain' \
        'AppleKeyboardUIMode' \
        -int 3
    # Follow the keyboard focus while zoomed in.
    defaults write \
        'com.apple.universalaccess' \
        'closeViewZoomFollowsFocus' \
        -bool true
    # Enable press-and-hold for accent marks in favor of key repeat.
    defaults write \
        'NSGlobalDomain' \
        'ApplePressAndHoldEnabled' \
        -bool true
    # Increase the speed of keyboard repeat rate.
    # This is very useful for keyboard-based navigation.
    #
    # Settings: System Preferences » Keyboard » Key Repeat/Delay Until Repeat
    #
    # Use the commands below to increase the key repeat rate on macOS beyond the
    # possible settings via the user interface. The changes aren't applied until
    # you restart your computer.
    #
    # Source: https://apple.stackexchange.com/a/83923
    # https://gist.github.com/hofmannsven/ff21749b0e6afc50da458bebbd9989c5
    #
    # Normal minimum here is 15 (225 ms).
    defaults write -g \
        'InitialKeyRepeat' \
        -int 15
    # Normal minimum here is 2 (30 ms). Use of 1 here is crazy fast.
    defaults write -g \
        'KeyRepeat' \
        -int 2
    # Set text formats.
    defaults write \
        'NSGlobalDomain' \
        'AppleLocale' \
        -string 'en_US@currency=USD'
    # Use the metric system.
    defaults write \
        'NSGlobalDomain' \
        'AppleMeasurementUnits' \
        -string 'Centimeters'
    defaults write \
        'NSGlobalDomain' \
        'AppleMetricUnits' \
        -bool true
    # Use scroll gesture with the Ctrl (^) modifier key to zoom.
    # > defaults write \
    # >     'com.apple.universalaccess' \
    # >     'closeViewScrollWheelToggle' \
    # >     -bool true
    # > defaults write \
    # >     'com.apple.universalaccess' \
    # >     'HIDScrollZoomModifierMask'\
    # >     -int 262144
    # Set language(s). Here's how to enable both English and Dutch, for example.
    # > defaults write \
    # >     'NSGlobalDomain' \
    # >     'AppleLanguages' \
    # >     -array 'en' 'nl'
    # Show language menu in the top right corner of the boot screen.
    # > sudo defaults write \
    # >     '/Library/Preferences/com.apple.loginwindow' \
    # >     'showInputMenu' \
    # >     -bool true
    # Increase sound quality for Bluetooth headphones/headsets.
    # > defaults write \
    # >     'com.apple.BluetoothAudioAgent' \
    # >     'Apple Bitpool Min (editable)' \
    # >     -int 40
    # Set the timezone; see 'sudo systemsetup -listtimezones' for other values.
    # > sudo systemsetup -settimezone 'America/New_York' > /dev/null
    # Power management {{{2
    # --------------------------------------------------------------------------
    # Check current settings.
    # > pmset -g
    # Restore power management defaults.
    # > pmset -c 2 -b 1 -u 1; pmset -g
    # Sleep the display after 15 minutes when connected to power.
    "${app[sudo]}" "${app[pmset]}" -c displaysleep 15
    # Screen {{{2
    # --------------------------------------------------------------------------
    # Require password immediately after sleep or screen saver begins.
    defaults write \
        'com.apple.screensaver' \
        'askForPassword' \
        -int 1
    defaults write \
        'com.apple.screensaver' \
        'askForPasswordDelay' \
        -int 0
    # Disable subpixel font rendering.
    # - https://github.com/kevinSuttle/macOS-Defaults/issues/
    #       17#issuecomment-266633501
    # - https://apple.stackexchange.com/questions/337870/
    # > defaults write -g \
    # >     'CGFontRenderingFontSmoothingDisabled' \
    # >     -bool YES
    defaults write \
        'NSGlobalDomain' \
        'AppleFontSmoothing' \
        -int 0
    # Set the default screenshot name prefix.
    defaults write \
        'com.apple.screencapture' \
        'name' \
        -string 'Screenshot'
    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF).
    defaults write \
        'com.apple.screencapture' \
        'type' \
        -string 'png'
    # Disable shadow in screenshots.
    defaults write \
        'com.apple.screencapture' \
        'disable-shadow' \
        -bool true
    # Save screenshots into Documents, instead of Desktop.
    screenshots_dir="${HOME}/Documents/screenshots"
    koopa::mkdir "$screenshots_dir"
    defaults write \
        'com.apple.screencapture' \
        'location' \
        "$screenshots_dir"
    # Enable HiDPI display modes (requires restart).
    # > sudo defaults write \
    # >     '/Library/Preferences/com.apple.windowserver' \
    # >     'DisplayResolutionEnabled' \
    # >     -bool true
    # Finder {{{2
    # --------------------------------------------------------------------------
    # Allow the Finder to quit. Doing so will also hide desktop icons.
    # > defaults write \
    # >     'com.apple.finder' \
    # >     'QuitMenuItem' \
    # >     -bool true
    # Show hidden files by default.
    # > defaults write \
    # >     'com.apple.finder' \
    # >     'AppleShowAllFiles' \
    # >     -bool true
    # Set Desktop as the default location for new Finder windows.
    # > defaults write \
    # >     'com.apple.finder' \
    # >     'NewWindowTarget' \
    # >     -string 'PfDe'
    # > defaults write \
    # >     'com.apple.finder' \
    # >     'NewWindowTargetPath' \
    # >     -string "file://${HOME}/Desktop/"
    # Set Documents as the default location for new Finder windows.
    defaults write \
        'com.apple.finder' \
        'NewWindowTarget' \
        -string 'PfLo'
    defaults write \
        'com.apple.finder' \
        'NewWindowTargetPath' \
        -string "file://${HOME}/Documents/"
    # Disable window animations and Get Info animations.
    defaults write \
        'com.apple.finder' \
        'DisableAllAnimations' \
        -bool true
    # Show icons for hard drives, servers, and removable media on the desktop.
    defaults write \
        'com.apple.finder' \
        'ShowExternalHardDrivesOnDesktop' \
        -bool true
    defaults write \
        'com.apple.finder' \
        'ShowHardDrivesOnDesktop' \
        -bool true
    defaults write \
        'com.apple.finder' \
        'ShowMountedServersOnDesktop' \
        -bool true
    defaults write \
        'com.apple.finder' \
        'ShowRemovableMediaOnDesktop' \
        -bool true
    # Show all filename extensions.
    defaults write \
        'NSGlobalDomain' \
        'AppleShowAllExtensions' \
        -bool true
    # Show status bar.
    defaults write \
        'com.apple.finder' \
        'ShowStatusBar' \
        -bool true
    # Show path bar.
    defaults write \
        'com.apple.finder' \
        'ShowPathbar' \
        -bool true
    # Display full POSIX path as Finder window title.
    # This looks terrible now on Big Sur, so disable.
    defaults write \
        'com.apple.finder' \
        '_FXShowPosixPathInTitle' \
        -bool false
    # Keep folders on top when sorting by name.
    defaults write \
        'com.apple.finder' \
        '_FXSortFoldersFirst' \
        -bool true
    # When performing a search, search the current folder by default.
    defaults write \
        'com.apple.finder' \
        'FXDefaultSearchScope' \
        -string 'SCcf'
    # Disable the warning when changing a file extension.
    defaults write \
        'com.apple.finder' \
        'FXEnableExtensionChangeWarning' \
        -bool false
    # Disable spring loading for directories.
    defaults write \
        'NSGlobalDomain' \
        'com.apple.springing.enabled' \
        -bool false
    # Remove the spring loading delay for directories.
    defaults write \
        'NSGlobalDomain' \
        'com.apple.springing.delay' \
        -float 0
    # Avoid creating .DS_Store files on network or USB volumes.
    defaults write \
        'com.apple.desktopservices' \
        'DSDontWriteNetworkStores' \
        -bool true
    defaults write \
        'com.apple.desktopservices' \
        'DSDontWriteUSBStores' \
        -bool true
    # Disable disk image verification.
    # > defaults write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'skip-verify' \
    # >     -bool true
    # > defaults write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'skip-verify-locked' \
    # >     -bool true
    # > defaults write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'skip-verify-remote' \
    # >     -bool true
    # Automatically open a new Finder window when a volume is mounted.
    # > defaults write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'auto-open-ro-root' \
    # >     -bool true
    # > defaults write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'auto-open-rw-root' \
    # >     -bool true
    # > defaults write \
    # >     'com.apple.finder' \
    # >     'OpenWindowForNewRemovableDisk' \
    # >     -bool true
    # Show item info near icons on the desktop and in other icon views.
    "${app[plistbuddy]}" \
        -c 'Set :DesktopViewSettings:IconViewSettings:showItemInfo true' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app[plistbuddy]}" \
        -c 'Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app[plistbuddy]}" \
        -c 'Set :StandardViewSettings:IconViewSettings:showItemInfo true' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Show item info to the right of the icons on the desktop.
    "${app[plistbuddy]}" \
        -c 'Set DesktopViewSettings:IconViewSettings:labelOnBottom false' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Sort icon views by name.
    # Alternatively, can use 'grid' here for snap-to-grid.
    "${app[plistbuddy]}" \
        -c 'Set :DesktopViewSettings:IconViewSettings:arrangeBy name' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app[plistbuddy]}" \
        -c 'Set :FK_StandardViewSettings:IconViewSettings:arrangeBy name' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app[plistbuddy]}" \
        -c 'Set :StandardViewSettings:IconViewSettings:arrangeBy name' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Set grid spacing for icons on the desktop and in other icon views.
    "${app[plistbuddy]}" \
        -c 'Set :DesktopViewSettings:IconViewSettings:gridSpacing 100' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app[plistbuddy]}" \
        -c 'Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app[plistbuddy]}" \
        -c 'Set :StandardViewSettings:IconViewSettings:gridSpacing 100' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Set the size of icons on the desktop and in other icon views.
    "${app[plistbuddy]}" \
        -c 'Set :DesktopViewSettings:IconViewSettings:iconSize 48' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app[plistbuddy]}" \
        -c 'Set :FK_StandardViewSettings:IconViewSettings:iconSize 48' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app[plistbuddy]}" \
        -c 'Set :StandardViewSettings:IconViewSettings:iconSize 48' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Use list view in all Finder windows by default.
    # Four-letter codes for the other view modes: 'icnv', 'clmv', 'glyv'
    defaults write \
        'com.apple.finder' \
        'FXPreferredViewStyle' \
        -string 'Nlsv'
    # Disable the warning before emptying the Trash.
    defaults write \
        'com.apple.finder' \
        'WarnOnEmptyTrash' \
        -bool false
    # Enable AirDrop over Ethernet and on unsupported Macs running Lion.
    defaults write \
        'com.apple.NetworkBrowser' \
        'BrowseAllInterfaces' \
        -bool true
    # Show the '~/Library' folder.
    chflags nohidden "${HOME}/Library"
    # Show the /Volumes folder.
    sudo chflags nohidden '/Volumes'
    # Expand the following File Info panes:
    # 'General', 'Open with', and 'Sharing & Permissions'
    defaults write \
        'com.apple.finder' \
        'FXInfoPanesExpanded' -dict \
            'General' -bool true \
            'OpenWith' -bool true \
            'Privileges' -bool true
    # Mac App Store {{{2
    # --------------------------------------------------------------------------
    # Enable the WebKit Developer Tools in the Mac App Store.
    defaults write \
        'com.apple.appstore' \
        'WebKitDeveloperExtras' \
        -bool true
    # Enable Debug Menu in the Mac App Store.
    defaults write \
        'com.apple.appstore' \
        'ShowDebugMenu' \
        -bool true
    # Enable the automatic update check.
    defaults write \
        'com.apple.SoftwareUpdate' \
        'AutomaticCheckEnabled' \
        -bool true
    # Download newly available updates in background.
    defaults write \
        'com.apple.SoftwareUpdate' \
        'AutomaticDownload' \
        -int 1
    # Install System data files & security updates.
    defaults write \
        'com.apple.SoftwareUpdate' \
        'CriticalUpdateInstall' \
        -int 1
    # Automatically download apps purchased on other Macs.
    defaults write \
        'com.apple.SoftwareUpdate' \
        'ConfigDataInstall' \
        -int 1
    # Turn on app auto-update.
    defaults write \
        'com.apple.commerce' \
        'AutoUpdate' \
        -bool true
    # Allow the App Store to reboot machine on macOS updates.
    defaults write \
        'com.apple.commerce' \
        'AutoUpdateRestartRequired' \
        -bool true
    # Check for software updates weekly.
    defaults write \
        'com.apple.SoftwareUpdate' \
        'ScheduleFrequency' \
        -int 7
    # Activity Monitor {{{2
    # --------------------------------------------------------------------------
    # Show the main window when launching Activity Monitor.
    defaults write \
        'com.apple.ActivityMonitor' \
        'OpenMainWindow' \
        -bool true
    # Visualize CPU usage in the Activity Monitor Dock icon.
    defaults write \
        'com.apple.ActivityMonitor' \
        'IconType' \
        -int 5
    # Show all processes in Activity Monitor.
    defaults write \
        'com.apple.ActivityMonitor' \
        'ShowCategory' \
        -int 0
    # Sort Activity Monitor results by CPU usage.
    defaults write \
        'com.apple.ActivityMonitor' \
        'SortColumn' \
        -string 'CPUUsage'
    defaults write \
        'com.apple.ActivityMonitor' \
        'SortDirection' \
        -int 0
    # Disk Utility {{{2
    # --------------------------------------------------------------------------
    # Enable the debug menu in Disk Utility.
    defaults write \
        'com.apple.DiskUtility' \
        'DUDebugMenuEnabled' \
        -bool true
    defaults write \
        'com.apple.DiskUtility' \
        'advanced-image-options' \
        -bool true
    # Spotlight {{{2
    # --------------------------------------------------------------------------
    # Hide Spotlight tray-icon (and subsequent helper).
    # > koopa::chmod --sudo '0600' \
    # >     '/System/Library/CoreServices/Search.bundle/Contents/MacOS/Search'
    # Disable Spotlight indexing for any volume that gets mounted and has not
    # yet been indexed before. Use 'sudo mdutil -i off /Volumes/foo' to stop
    # indexing any volume.
    # > sudo defaults write \
    # >     '/.Spotlight-V100/VolumeConfiguration' \
    # >     'Exclusions' \
    # >     -array '/Volumes'
    # Load new settings before rebuilding the index.
    # > killall mds > /dev/null 2>&1
    # Make sure indexing is enabled for the main volume.
    # > sudo mdutil -i on / > /dev/null
    # Rebuild the index from scratch.
    # > sudo mdutil -E / > /dev/null
    # Time Machine {{{2
    # --------------------------------------------------------------------------
    # Prevent Time Machine from prompting to use new hard drives as backup.
    defaults write \
        'com.apple.TimeMachine' \
        'DoNotOfferNewDisksForBackup' \
        -bool true
    # Disable local Time Machine backups.
    # Note that this doesn't seem to be working in Catalina.
    # > hash tmutil &> /dev/null && sudo tmutil disablelocal
    # Safari {{{2
    # --------------------------------------------------------------------------
    # Check the defaults with 'defaults read -app Safari'.
    # Privacy: don't send search queries to Apple.
    defaults write \
        'com.apple.Safari' \
        'UniversalSearchEnabled' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        'SuppressSearchSuggestions' \
        -bool true
    # Press Tab to highlight each item on a web page.
    defaults write \
        'com.apple.Safari' \
        'WebKitTabToLinksPreferenceKey' \
        -bool true
    defaults write \
        'com.apple.Safari' \
        'com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks' \
        -bool true
    # Show the full URL in the address bar (note: this still hides the scheme).
    defaults write \
        'com.apple.Safari' \
        'ShowFullURLInSmartSearchField' \
        -bool true
    # Set Safari's home page to 'about:blank' for faster loading.
    defaults write \
        'com.apple.Safari' \
        'HomePage' \
        -string 'about:blank'
    # Prevent Safari from opening 'safe' files automatically after downloading.
    defaults write \
        'com.apple.Safari' \
        'AutoOpenSafeDownloads' \
        -bool false
    # Allow hitting the Backspace key to go to the previous page in history.
    defaults write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2BackspaceKeyNavigationEnabled" \
        -bool true
    # Hide Safari's bookmarks bar by default.
    defaults write \
        'com.apple.Safari' \
        'ShowFavoritesBar' \
        -bool false
    # Hide Safari's sidebar in Top Sites.
    defaults write \
        'com.apple.Safari' \
        'ShowSidebarInTopSites' \
        -bool false
    # Disable Safari's thumbnail cache for History and Top Sites.
    defaults write \
        'com.apple.Safari' \
        'DebugSnapshotsUpdatePolicy' \
        -int 2
    # Enable Safari's debug menu.
    defaults write \
        'com.apple.Safari' \
        'IncludeInternalDebugMenu' \
        -bool true
    # Make Safari's search banners default to Contains instead of Starts With.
    defaults write \
        'com.apple.Safari' \
        'FindOnPageMatchesWordStartsOnly' \
        -bool false
    # Remove useless icons from Safari's bookmarks bar.
    # > defaults write \
    # >     'com.apple.Safari' \
    # >     'ProxiesInBookmarksBar' \
    # >     '()'
    # Enable the Develop menu and the Web Inspector in Safari.
    defaults write \
        'com.apple.Safari' \
        'IncludeDevelopMenu' \
        -bool true
    defaults write \
        'com.apple.Safari' \
        'WebKitDeveloperExtrasEnabledPreferenceKey' \
        -bool true
    defaults write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2DeveloperExtrasEnabled" \
        -bool true
    # Add a context menu item for showing the Web Inspector in web views.
    defaults write \
        'NSGlobalDomain' \
        'WebKitDeveloperExtras' \
        -bool true
    # Disable continuous spellchecking.
    defaults write \
        'com.apple.Safari' \
        'WebContinuousSpellCheckingEnabled' \
        -bool false
    # Disable auto-correct.
    defaults write \
        'com.apple.Safari' \
        'WebAutomaticSpellingCorrectionEnabled' \
        -bool false
    # Disable AutoFill.
    defaults write \
        'com.apple.Safari' \
        'AutoFillFromAddressBook' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        'AutoFillPasswords' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        'AutoFillCreditCardData' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        'AutoFillMiscellaneousForms' \
        -bool false
    # Warn about fraudulent websites.
    defaults write \
        'com.apple.Safari' \
        'WarnAboutFraudulentWebsites' \
        -bool true
    # Disable plug-ins.
    defaults write \
        'com.apple.Safari' \
        'WebKitPluginsEnabled' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        'com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled' \
        -bool false
    # Disable Java.
    defaults write \
        'com.apple.Safari' \
        'WebKitJavaEnabled' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        'com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2JavaEnabledForLocalFiles" \
        -bool false
    # Block pop-up windows.
    defaults write \
        'com.apple.Safari' \
        'WebKitJavaScriptCanOpenWindowsAutomatically' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2JavaScriptCanOpenWindowsAutomatically" \
        -bool false
    # Enable 'Do Not Track'.
    defaults write \
        'com.apple.Safari' \
        'SendDoNotTrackHTTPHeader' \
        -bool true
    # Update extensions automatically.
    defaults write \
        'com.apple.Safari' \
        'InstallExtensionUpdatesAutomatically' \
        -bool true
    # Disable auto-playing video.
    defaults write \
        'com.apple.Safari' \
        'WebKitMediaPlaybackAllowsInline' \
        -bool false
    defaults write \
        'com.apple.SafariTechnologyPreview' \
        'WebKitMediaPlaybackAllowsInline' \
        -bool false
    defaults write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2AllowsInlineMediaPlayback" \
        -bool false
    defaults write \
        'com.apple.SafariTechnologyPreview' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2AllowsInlineMediaPlayback" \
        -bool false
    # Mail {{{2
    # --------------------------------------------------------------------------
    # Disable send and reply animations in Mail.app.
    defaults write \
        'com.apple.mail' \
        'DisableReplyAnimations' \
        -bool true
    defaults write \
        'com.apple.mail' \
        'DisableSendAnimations' \
        -bool true
    # Copy email addresses as 'foo@example.com' instead of
    # 'Foo Bar <foo@example.com>' in Mail.app.
    defaults write \
        'com.apple.mail' \
        'AddressesIncludeNameOnPasteboard' \
        -bool false
    # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app.
    defaults write \
        'com.apple.mail' \
        'NSUserKeyEquivalents' \
        -dict-add 'Send' '@\U21a9'
    # Display emails in threaded mode, sorted by date (oldest at the top).
    defaults write \
        'com.apple.mail' \
        'DraftsViewerAttributes' \
        -dict-add 'DisplayInThreadedMode' -string 'yes'
    defaults write \
        'com.apple.mail' \
        'DraftsViewerAttributes' \
        -dict-add 'SortedDescending' -string 'no'
    defaults write \
        'com.apple.mail' \
        'DraftsViewerAttributes' \
        -dict-add 'SortOrder' -string 'received-date'
    # Disable inline attachments (just show the icons).
    defaults write \
        'com.apple.mail' \
        'DisableInlineAttachmentViewing' \
        -bool true
    # Disable automatic spell checking.
    defaults write \
        'com.apple.mail' \
        'SpellCheckingBehavior' \
        -string 'NoSpellCheckingEnabled'
    # Terminal {{{2
    # --------------------------------------------------------------------------
    # Only use UTF-8 in Terminal.app.
    defaults write \
        'com.apple.terminal' \
        'StringEncodings' \
        -array 4
    # Enable Secure Keyboard Entry in Terminal.app.
    # See: https://security.stackexchange.com/a/47786/8918
    defaults write \
        'com.apple.terminal' \
        'SecureKeyboardEntry' \
        -bool true
    # Disable the annoying line marks.
    defaults write \
        'com.apple.Terminal' \
        'ShowLineMarks' \
        -int 0
    # iTerm {{{2
    # --------------------------------------------------------------------------
    # Don't display the annoying prompt when quitting iTerm.
    defaults write \
        'com.googlecode.iterm2' \
        'PromptOnQuit' \
        -bool false
    # iTunes {{{2
    # --------------------------------------------------------------------------
    # Disable podcasts in iTunes.
    defaults write \
        'com.apple.itunes' \
        'disablePodcasts' \
        -bool YES
    # Stop iTunes from responding to the keyboard media keys.
    # > launchctl unload \
    # >     -w '/System/Library/LaunchAgents/com.apple.rcd.plist' \
    # >     2> /dev/null
    # Messages {{{2
    # --------------------------------------------------------------------------
    # Disable automatic emoji substitution (i.e. use plain text smileys).
    defaults write \
        'com.apple.messageshelper.MessageController' \
        'SOInputLineSettings' \
        -dict-add 'automaticEmojiSubstitutionEnablediMessage' \
        -bool false
    # Disable smart quotes as it's annoying for messages that contain code.
    defaults write \
        'com.apple.messageshelper.MessageController' \
        'SOInputLineSettings' \
        -dict-add 'automaticQuoteSubstitutionEnabled' \
        -bool false
    # Disable continuous spell checking.
    defaults write \
        'com.apple.messageshelper.MessageController' \
        'SOInputLineSettings' \
        -dict-add 'continuousSpellCheckingEnabled' \
        -bool false
    # Photos {{{2
    # --------------------------------------------------------------------------
    # Prevent Photos from opening automatically when devices are plugged in.
    defaults -currentHost write \
        'com.apple.ImageCapture' \
        'disableHotPlug' \
        -bool true
    # TextEdit {{{2
    # --------------------------------------------------------------------------
    # Use plain text mode for new TextEdit documents.
    defaults write \
        'com.apple.TextEdit' \
        'RichText' \
        -int 0
    # Open and save files as UTF-8 in TextEdit.
    defaults write \
        'com.apple.TextEdit' \
        'PlainTextEncoding' \
        -int 4
    defaults write \
        'com.apple.TextEdit' \
        'PlainTextEncodingForWrite' \
        -int 4
    # Google Chrome and Google Chrome Canary {{{2
    # --------------------------------------------------------------------------
    # Disable the all too sensitive backswipe on trackpads.
    defaults write \
        'com.google.Chrome' \
        'AppleEnableSwipeNavigateWithScrolls' \
        -bool false
    defaults write \
        'com.google.Chrome.canary' \
        'AppleEnableSwipeNavigateWithScrolls' \
        -bool false
    # Disable the all too sensitive backswipe on Magic Mouse.
    defaults write \
        'com.google.Chrome' \
        'AppleEnableMouseSwipeNavigateWithScrolls' \
        -bool false
    defaults write \
        'com.google.Chrome.canary' \
        'AppleEnableMouseSwipeNavigateWithScrolls' \
        -bool false
    # Use the system-native print preview dialog.
    defaults write \
        'com.google.Chrome' \
        'DisablePrintPreview' \
        -bool true
    defaults write \
        'com.google.Chrome.canary' \
        'DisablePrintPreview' \
        -bool true
    # Expand the print dialog by default.
    defaults write \
        'com.google.Chrome' \
        'PMPrintingExpandedStateForPrint2' \
        -bool true
    defaults write \
        'com.google.Chrome.canary' \
        'PMPrintingExpandedStateForPrint2' \
        -bool true
    # GPGMail {{{2
    # --------------------------------------------------------------------------
    # Disable signing emails by default
    defaults write \
        "${HOME}/Library/Preferences/org.gpgtools.gpgmail" \
        'SignNewEmailsByDefault' \
        -bool false
    # Tweetbot {{{2
    # --------------------------------------------------------------------------
    # Bypass the annoyingly slow t.co URL shortener.
    defaults write \
        'com.tapbots.TweetbotMac' \
        'OpenURLsDirectly' \
        -bool true
    # Final steps {{{2
    # --------------------------------------------------------------------------
    # Remove duplicates in the 'Open With' menu (also see 'lscleanup' alias).
    "${app[lsregister]}" \
        -kill -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    # Kill affected apps.
    for app_name in \
        'Activity Monitor' \
        'Dock' \
        'Finder' \
        'Google Chrome' \
        'SystemUIServer' \
        'Tweetbot' \
        'cfprefsd'
    do
        "${app[kill_all]}" "${app_name}" &>/dev/null || true
    done
    koopa::update_success "${dict[name_fancy]}"
    koopa::alert_note 'Some of these changes require logout to take effect.'
    return 0
}
