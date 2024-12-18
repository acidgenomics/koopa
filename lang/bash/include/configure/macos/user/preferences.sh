#!/usr/bin/env bash

# TODO Add support for disabling alert sounds.
# TODO Add support for disabling window snapping on macOS 15.

main() {
    # """
    # Configure macOS user defaults.
    # @note Updated 2024-12-18.
    #
    # How to read current value:
    # defaults read 'com.apple.AppleMultitouchTrackpad'
    #
    # By default sets value in '~/Library/Preferences/.GlobalPreferences.plist'.
    #
    # The '-currentHost' flag sets value in:
    # '~/Library/Preferences/ByHost/.GlobalPreferences.<UUID>.plist'.
    #
    # Hardware UUID can be determined with:
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
    # - https://github.com/hkloudou/macstarter/blob/main/system/screenshot.sh
    # """
    local -A app dict
    local -a app_names
    local app_name
    app['chflags']="$(koopa_macos_locate_chflags)"
    app['defaults']="$(koopa_macos_locate_defaults)"
    app['kill_all']="$(koopa_macos_locate_kill_all)"
    app['lsregister']="$(koopa_macos_locate_lsregister)"
    app['plistbuddy']="$(koopa_macos_locate_plistbuddy)"
    koopa_assert_is_executable "${app[@]}"
    dict['screenshots_dir']="${HOME}/Pictures/screenshots"
    koopa_alert_note "If you encounter permission errors when attempting to \
write defaults, ensure that your terminal app has full disk access enabled." \
    'System Preferences > Security & Privacy > Privacy > Full Disk Access'
    koopa_h2 'General UI/UX'
    # Disable click wallpaper to reveal desktop. Added in Sonoma.
    # System Settings > Desktop & Dock > Desktop & Stage Manager >
    # Click wallpaper to reveal desktop > Only in Stage Manager
    # - https://derflounder.wordpress.com/2023/09/26/managing-the-click-
    #     wallpaper-to-reveal-desktop-setting-in-macos-sonoma/
    "${app['defaults']}" write \
        'com.apple.WindowManager' \
        'EnableStandardClickToShowDesktop' \
        -bool false
    # Reduce motion.
    "${app['defaults']}" write \
        'com.apple.universalaccess' \
        'reduceMotion' \
        -bool true
    # Reduce transparency. This makes the menu bar consistently dark on Big Sur
    # but will add an annoying border to the Dock. Nothing you can do about
    # that -- it's worth the trade off of avoiding a menu bar that switches to
    # light mode depending on the desktop wallpaper.
    # > defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool false
    "${app['defaults']}" write \
        'com.apple.universalaccess' \
        'reduceTransparency' \
        -bool true
    # Differentiate without color.
    "${app['defaults']}" write \
        'com.apple.universalaccess' \
        'differentiateWithoutColor' \
        -bool true
    # Enable Dark mode by default.
    # To disable, delete entry with 'defaults delete'.
    "${app['defaults']}" write \
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
    # > "${app['defaults']}" write \
    # >     -globalDomain 'AppleAquaColorVariant' \
    # >     -int 1
    # > "${app['defaults']}" write \
    # >     -globalDomain 'AccentColor' \
    # >     -int 1
    # > "${app['defaults']}" write \
    # >     -globalDomain 'AppleHighlightColor' \
    # >     -string '1.000000 0.874510 0.701961 Orange'
    #
    # Set sidebar icon size to medium.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSTableViewDefaultSizeMode' \
        -int 2
    # Set the default scrollbar appearance.
    # Possible values: 'WhenScrolling', 'Automatic' and 'Always'.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'AppleShowScrollBars' \
        -string 'Automatic'
    # Disable the over-the-top focus ring animation.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSUseAnimatedFocusRing' \
        -bool false
    # Expand save panel by default.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSNavPanelExpandedStateForSaveMode' \
        -bool true
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSNavPanelExpandedStateForSaveMode2' \
        -bool true
    # Expand print panel by default.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'PMPrintingExpandedStateForPrint' \
        -bool true
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'PMPrintingExpandedStateForPrint2' \
        -bool true
    # Save to disk (not to iCloud) by default.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSDocumentSaveNewDocumentsToCloud' \
        -bool false
    # Automatically quit printer app once the print jobs complete.
    "${app['defaults']}" write \
        'com.apple.print.PrintingPrefs' \
        'Quit When Finished' \
        -bool true
    # Disable the 'Are you sure you want to open this application?' dialog.
    "${app['defaults']}" write \
        'com.apple.LaunchServices' \
        'LSQuarantine' \
        -bool false
    # Disable resume system-wide.
    "${app['defaults']}" write \
        'com.apple.systempreferences' \
        'NSQuitAlwaysKeepsWindows' \
        -bool false
    # Disable automatic termination of inactive apps.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSDisableAutomaticTermination' \
        -bool true
    # Set Help Viewer windows to non-floating mode.
    "${app['defaults']}" write \
        'com.apple.helpviewer' \
        'DevMode' \
        -bool true
    # Disable automatic capitalization as it's annoying when typing code.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSAutomaticCapitalizationEnabled' \
        -bool false
    # Disable smart dashes as they're annoying when typing code.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSAutomaticDashSubstitutionEnabled' \
        -bool false
    # Disable automatic period substitution as it's annoying when typing code.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSAutomaticPeriodSubstitutionEnabled' \
        -bool false
    # Disable smart quotes as they're annoying when typing code.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSAutomaticQuoteSubstitutionEnabled' \
        -bool false
    # Disable auto-correct.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSAutomaticSpellingCorrectionEnabled' \
        -bool false
    # Increase window resize speed for Cocoa applications.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'NSWindowResizeTime' \
        '.001'
    koopa_h2 'Handoff'
    # Disabling handoff by default.
    # https://superuser.com/questions/1420107/
    # https://superuser.com/a/1613808
    "${app['defaults']}" -currentHost write \
        'com.apple.coreservices.useractivityd' \
        'ActivityAdvertisingAllowed' \
        -bool false
    "${app['defaults']}" -currentHost write \
        'com.apple.coreservices.useractivityd' \
        'ActivityReceivingAllowed' \
        -bool false
    koopa_h2 'Dock, Dashboard, and hot corners'
    # Enable highlight hover effect for the grid view of a stack (Dock).
    "${app['defaults']}" write \
        'com.apple.dock' \
        'mouse-over-hilite-stack' \
        -bool true
    # Set the icon size of Dock items to 36 pixels.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'tilesize' \
        -int 36
    # Change minimize/maximize window effect.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'mineffect' \
        -string 'scale'
    # Minimize windows into their application's icon.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'minimize-to-application' \
        -bool true
    # Disable spring loading for all Dock items.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'enable-spring-load-actions-on-all-items' \
        -bool false
    # Show indicator lights for open applications in the Dock.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'show-process-indicators' \
        -bool true
    # Don't animate opening applications from the Dock.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'launchanim' \
        -bool false
    # Speed up Mission Control animations.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'expose-animation-duration' \
        -float 0.1
    # Don't group windows by application in Mission Control (i.e. use the old
    # Exposé behavior instead).
    "${app['defaults']}" write \
        'com.apple.dock' \
        'expose-group-by-app' \
        -bool false
    # Disable Dashboard.
    "${app['defaults']}" write \
        'com.apple.dashboard' \
        'mcx-disabled' \
        -bool true
    # Don't show Dashboard as a Space.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'dashboard-in-overlay' \
        -bool true
    # Don't automatically rearrange Spaces based on most recent use.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'mru-spaces' \
        -bool false
    # Remove the auto-hiding Dock delay.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'autohide-delay' \
        -float 0
    # Remove the animation when hiding/showing the Dock.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'autohide-time-modifier' \
        -float 0
    # Automatically hide and show the Dock.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'autohide' \
        -bool true
    # Make Dock icons of hidden applications translucent.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'showhidden' \
        -bool true
    # Don't show recent applications in Dock.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'show-recents' \
        -bool false
    # Disable the Launchpad gesture (pinch with thumb and three fingers).
    "${app['defaults']}" write \
        'com.apple.dock' \
        'showLaunchpadGestureEnabled' \
        -int 0
    # Wipe all (default) app icons from the Dock.
    # This is only really useful when setting up a new Mac, or if you don't use
    # the Dock to launch apps.
    # > "${app['defaults']}" write 'com.apple.dock' 'persistent-apps' -array
    # Show only open applications in the Dock.
    # > "${app['defaults']}" write 'com.apple.dock' 'static-only' -bool true
    # Add a spacer to the left side of the Dock (where the applications are).
    # > "${app['defaults']}" write \
    # >     'com.apple.dock' \
    # >     'persistent-apps' \
    # >     -array-add '{tile-data={}; tile-type="spacer-tile";}'
    # Add a spacer to the right side of the Dock (where the Trash is).
    # > "${app['defaults']}" write \
    # >     'com.apple.dock' \
    # >     'persistent-others' \
    # >     -array-add '{tile-data={}; tile-type="spacer-tile";}'
    # Hot corners.
    # Possible values:
    #  0: No action
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
    # Top left screen corner: None.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'wvous-tl-corner' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.dock' \
        'wvous-tl-modifier' \
        -int 0
    # Top right screen corner: Lock Screen.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'wvous-tr-corner' \
        -int 13
    "${app['defaults']}" write \
        'com.apple.dock' \
        'wvous-tr-modifier' \
        -int 0
    # Bottom left screen corner: None.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'wvous-bl-corner' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.dock' \
        'wvous-bl-modifier' \
        -int 0
    # Bottom right screen corner: None.
    "${app['defaults']}" write \
        'com.apple.dock' \
        'wvous-br-corner' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.dock' \
        'wvous-br-modifier' \
        -int 0
    koopa_h2 'Keyboard, mouse, trackpad, and other input'
    # Set the tracking speed.
    # The maximum speed you can access from the System Preferences is 3.0.
    # Higher values indicate faster tracking.
    # https://www.defaults-write.com/
    #     change-your-mouse-tracking-speed-in-mac-os-x/
    "${app['defaults']}" write -g \
        'com.apple.mouse.scaling' \
        2.0
    "${app['defaults']}" write -g \
        'com.apple.trackpad.scaling' \
        2.0
    # Read the current tracking speed.
    # > "${app['defaults']}" read -g 'com.apple.mouse.scaling'
    # > "${app['defaults']}" read -g 'com.apple.trackpad.scaling'
    # Restore to default tracking speed.
    # > "${app['defaults']}" delete -g 'com.apple.mouse.scaling'
    # > "${app['defaults']}" delete -g 'com.apple.trackpad.scaling'
    # Configure multi-touch trackpad.
    # Read current settings.
    # > "${app['defaults']}" read \
    # >     'com.apple.AppleMultitouchTrackpad'
    # > "${app['defaults']}" read \
    # >     'com.apple.driver.AppleBluetoothMultitouch.trackpad'
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'ActuateDetents' \
        -int 0  # 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'ActuationStrength' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'Clicking' \
        -int 1  # 0
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'DragLock' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'Dragging' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'FirstClickThreshold' \
        -int 0  # 1 (medium)
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'ForceSuppressed' \
        -int 1  # 0
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'SecondClickThreshold' \
        -int 0  # 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadCornerSecondaryClick' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadFiveFingerPinchGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadFourFingerHorizSwipeGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadFourFingerPinchGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadFourFingerVertSwipeGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadHandResting' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadHorizScroll' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadMomentumScroll' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadPinch' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadRightClick' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadRotate' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadScroll' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadThreeFingerDrag' \
        -int 1  # 0
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadThreeFingerHorizSwipeGesture' \
        -int 0  # 2
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadThreeFingerTapGesture' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadThreeFingerVertSwipeGesture' \
        -int 0  # 2
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadTwoFingerDoubleTapGesture' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.AppleMultitouchTrackpad' \
        'TrackpadTwoFingerFromRightEdgeSwipeGesture' \
        -int 3
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'Clicking' \
        -int 1  # 0
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'DragLock' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'Dragging' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadCornerSecondaryClick' \
        -int 2  # 0
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadFiveFingerPinchGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadFourFingerHorizSwipeGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadFourFingerPinchGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadFourFingerVertSwipeGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadHandResting' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadHorizScroll' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadMomentumScroll' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadPinch' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadRightClick' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadRotate' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadScroll' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerDrag' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerDrag' \
        -int 1  # 0
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerHorizSwipeGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerTapGesture' \
        -int 0
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadThreeFingerVertSwipeGesture' \
        -int 2
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadTwoFingerDoubleTapGesture' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.driver.AppleBluetoothMultitouch.trackpad' \
        'TrackpadTwoFingerFromRightEdgeSwipeGesture' \
        -int 3
    # Disable look up and data detectors.
    "${app['defaults']}" -currentHost write -g \
        'com.apple.trackpad.threeFingerTapGesture' \
        -int 0
    # Enable secondary click.
    "${app['defaults']}" -currentHost write NSGlobalDomain \
        'com.apple.trackpad.enableSecondaryClick' \
        -bool true
    # Enable tap to click for this user and for the login screen.
    "${app['defaults']}" -currentHost write NSGlobalDomain \
        'com.apple.mouse.tapBehavior' \
        -int 1
    "${app['defaults']}" write NSGlobalDomain \
        'com.apple.mouse.tapBehavior' \
        -int 1
    # Map bottom right corner to right-click.
    "${app['defaults']}" -currentHost write NSGlobalDomain \
        'com.apple.trackpad.trackpadCornerClickBehavior' \
        -int 1
    # Enable natural scroll direction.
    "${app['defaults']}" write NSGlobalDomain \
        'com.apple.swipescrolldirection' \
        -bool true
    # Enable full keyboard access for all controls (e.g. Tab in modal dialogs).
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'AppleKeyboardUIMode' \
        -int 3
    # Follow the keyboard focus while zoomed in.
    "${app['defaults']}" write \
        'com.apple.universalaccess' \
        'closeViewZoomFollowsFocus' \
        -bool true
    # Enable press-and-hold for accent marks in favor of key repeat.
    "${app['defaults']}" write \
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
    "${app['defaults']}" write -g \
        'InitialKeyRepeat' \
        -int 15
    # Normal minimum here is 2 (30 ms). Use of 1 here is crazy fast.
    "${app['defaults']}" write -g \
        'KeyRepeat' \
        -int 2
    # Set text formats.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'AppleLocale' \
        -string 'en_US@currency=USD'
    # Use the metric system.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'AppleMeasurementUnits' \
        -string 'Centimeters'
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'AppleMetricUnits' \
        -bool true
    # Use scroll gesture with the Ctrl (^) modifier key to zoom.
    # > "${app['defaults']}" write \
    # >     'com.apple.universalaccess' \
    # >     'closeViewScrollWheelToggle' \
    # >     -bool true
    # > "${app['defaults']}" write \
    # >     'com.apple.universalaccess' \
    # >     'HIDScrollZoomModifierMask'\
    # >     -int 262144
    # Set language(s). Here's how to enable both English and Dutch, for example.
    # > "${app['defaults']}" write \
    # >     'NSGlobalDomain' \
    # >     'AppleLanguages' \
    # >     -array 'en' 'nl'
    # Increase sound quality for Bluetooth headphones/headsets.
    # > "${app['defaults']}" write \
    # >     'com.apple.BluetoothAudioAgent' \
    # >     'Apple Bitpool Min (editable)' \
    # >     -int 40
    koopa_h2 'Screen'
    # Require password immediately after sleep or screen saver begins.
    "${app['defaults']}" write \
        'com.apple.screensaver' \
        'askForPassword' \
        -int 1
    "${app['defaults']}" write \
        'com.apple.screensaver' \
        'askForPasswordDelay' \
        -int 0
    # Disable subpixel font rendering.
    # - https://github.com/kevinSuttle/macOS-Defaults/issues/
    #       17#issuecomment-266633501
    # - https://apple.stackexchange.com/questions/337870/
    # > "${app['defaults']}" write -g \
    # >     'CGFontRenderingFontSmoothingDisabled' \
    # >     -bool YES
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'AppleFontSmoothing' \
        -int 0
    koopa_h2 'Screenshots'
    # Set the default screenshot name prefix.
    "${app['defaults']}" write \
        'com.apple.screencapture' \
        'name' \
        -string 'Screenshot'
    # Include date in screenshot file name. There's no way to customize
    # currently (e.g. to 'YYYY-MM-DD-HH-MM-SS'). The current default
    # ('YYYY-MM-DD at hh:mm:ss a') is not ideal.
    "${app['defaults']}" write \
        'com.apple.screencapture' \
        'include-date' \
        -bool true
    # Don't clutter the desktop with screenshots.
    koopa_mkdir "${dict['screenshots_dir']}"
    "${app['defaults']}" write \
        'com.apple.screencapture' \
        'location' \
        "${dict['screenshots_dir']}"
    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF).
    "${app['defaults']}" write \
        'com.apple.screencapture' \
        'type' \
        -string 'png'
    # Hide the mouse pointer in screenshots.
    "${app['defaults']}" write \
        'com.apple.screencapture' \
        'showsCursor' \
        -bool false
    # Disable shadow in screenshots.
    "${app['defaults']}" write \
        'com.apple.screencapture' \
        'disable-shadow' \
        -bool true
    # Disable the floating thumbnail preview in bottom corner of screen.
    # Incredibly annoying default brought over from iOS. If this plist setting
    # breaks in the future, here's how to disable using the GUI:
    # CMD + SHIFT + 5 > click 'Options' > uncheck 'Show Floating Thumbnail'.
    "${app['defaults']}" write \
        'com.apple.screencapture' \
        'show-thumbnail' \
        -bool false
    koopa_h2 'Finder'
    # Allow the Finder to quit. Doing so will also hide desktop icons.
    # > "${app['defaults']}" write \
    # >     'com.apple.finder' \
    # >     'QuitMenuItem' \
    # >     -bool true
    # Show hidden files by default.
    # > "${app['defaults']}" write \
    # >     'com.apple.finder' \
    # >     'AppleShowAllFiles' \
    # >     -bool true
    # Set Desktop as the default location for new Finder windows.
    # > "${app['defaults']}" write \
    # >     'com.apple.finder' \
    # >     'NewWindowTarget' \
    # >     -string 'PfDe'
    # > "${app['defaults']}" write \
    # >     'com.apple.finder' \
    # >     'NewWindowTargetPath' \
    # >     -string "file://${HOME}/Desktop/"
    # Set Documents as the default location for new Finder windows.
    "${app['defaults']}" write \
        'com.apple.finder' \
        'NewWindowTarget' \
        -string 'PfLo'
    "${app['defaults']}" write \
        'com.apple.finder' \
        'NewWindowTargetPath' \
        -string "file://${HOME}/Documents/"
    # Disable window animations and Get Info animations.
    "${app['defaults']}" write \
        'com.apple.finder' \
        'DisableAllAnimations' \
        -bool true
    # Show icons for hard drives, servers, and removable media on the desktop.
    "${app['defaults']}" write \
        'com.apple.finder' \
        'ShowExternalHardDrivesOnDesktop' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.finder' \
        'ShowHardDrivesOnDesktop' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.finder' \
        'ShowMountedServersOnDesktop' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.finder' \
        'ShowRemovableMediaOnDesktop' \
        -bool true
    # Show all filename extensions.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'AppleShowAllExtensions' \
        -bool true
    # Show status bar.
    "${app['defaults']}" write \
        'com.apple.finder' \
        'ShowStatusBar' \
        -bool true
    # Show path bar.
    "${app['defaults']}" write \
        'com.apple.finder' \
        'ShowPathbar' \
        -bool true
    # Disable full POSIX path as Finder window title.
    "${app['defaults']}" write \
        'com.apple.finder' \
        '_FXShowPosixPathInTitle' \
        -bool false
    # Keep folders on top when sorting by name.
    "${app['defaults']}" write \
        'com.apple.finder' \
        '_FXSortFoldersFirst' \
        -bool true
    # When performing a search, search the current folder by default.
    "${app['defaults']}" write \
        'com.apple.finder' \
        'FXDefaultSearchScope' \
        -string 'SCcf'
    # Disable the warning when changing a file extension.
    "${app['defaults']}" write \
        'com.apple.finder' \
        'FXEnableExtensionChangeWarning' \
        -bool false
    # Disable spring loading for directories.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'com.apple.springing.enabled' \
        -bool false
    # Remove the spring loading delay for directories.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'com.apple.springing.delay' \
        -float 0
    # Avoid creating '.DS_Store' files on network or USB volumes. These will
    # still get created on NFS shares, but there doesn't seem to be a way to
    # prevent this from happening.
    "${app['defaults']}" write \
        'com.apple.desktopservices' \
        'DSDontWriteNetworkStores' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.desktopservices' \
        'DSDontWriteUSBStores' \
        -bool true
    # Disable disk image verification.
    # > "${app['defaults']}" write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'skip-verify' \
    # >     -bool true
    # > "${app['defaults']}" write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'skip-verify-locked' \
    # >     -bool true
    # > "${app['defaults']}" write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'skip-verify-remote' \
    # >     -bool true
    # Automatically open a new Finder window when a volume is mounted.
    # > "${app['defaults']}" write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'auto-open-ro-root' \
    # >     -bool true
    # > "${app['defaults']}" write \
    # >     'com.apple.frameworks.diskimages' \
    # >     'auto-open-rw-root' \
    # >     -bool true
    # > "${app['defaults']}" write \
    # >     'com.apple.finder' \
    # >     'OpenWindowForNewRemovableDisk' \
    # >     -bool true
    # Show item info near icons on the desktop and in other icon views.
    "${app['plistbuddy']}" \
        -c 'Set :DesktopViewSettings:IconViewSettings:showItemInfo true' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app['plistbuddy']}" \
        -c 'Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app['plistbuddy']}" \
        -c 'Set :StandardViewSettings:IconViewSettings:showItemInfo true' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Show item info to the right of the icons on the desktop.
    "${app['plistbuddy']}" \
        -c 'Set DesktopViewSettings:IconViewSettings:labelOnBottom false' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Sort icon views by name.
    # Alternatively, can use 'grid' here for snap-to-grid.
    "${app['plistbuddy']}" \
        -c 'Set :DesktopViewSettings:IconViewSettings:arrangeBy name' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app['plistbuddy']}" \
        -c 'Set :FK_StandardViewSettings:IconViewSettings:arrangeBy name' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app['plistbuddy']}" \
        -c 'Set :StandardViewSettings:IconViewSettings:arrangeBy name' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Set grid spacing for icons on the desktop and in other icon views.
    "${app['plistbuddy']}" \
        -c 'Set :DesktopViewSettings:IconViewSettings:gridSpacing 100' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app['plistbuddy']}" \
        -c 'Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app['plistbuddy']}" \
        -c 'Set :StandardViewSettings:IconViewSettings:gridSpacing 100' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Set the size of icons on the desktop and in other icon views.
    "${app['plistbuddy']}" \
        -c 'Set :DesktopViewSettings:IconViewSettings:iconSize 48' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app['plistbuddy']}" \
        -c 'Set :FK_StandardViewSettings:IconViewSettings:iconSize 48' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    "${app['plistbuddy']}" \
        -c 'Set :StandardViewSettings:IconViewSettings:iconSize 48' \
        "${HOME}/Library/Preferences/com.apple.finder.plist"
    # Use list view in all Finder windows by default.
    # Four-letter codes for the other view modes: 'icnv', 'clmv', 'glyv'
    "${app['defaults']}" write \
        'com.apple.finder' \
        'FXPreferredViewStyle' \
        -string 'Nlsv'
    # Disable the warning before emptying the Trash.
    "${app['defaults']}" write \
        'com.apple.finder' \
        'WarnOnEmptyTrash' \
        -bool false
    # Enable AirDrop over Ethernet and on unsupported Macs running Lion.
    "${app['defaults']}" write \
        'com.apple.NetworkBrowser' \
        'BrowseAllInterfaces' \
        -bool true
    # Show the '~/Library' folder.
    "${app['chflags']}" nohidden "${HOME}/Library"
    # Expand the following File Info panes:
    # 'General', 'Open with', and 'Sharing & Permissions'
    "${app['defaults']}" write \
        'com.apple.finder' \
        'FXInfoPanesExpanded' -dict \
            'General' -bool true \
            'OpenWith' -bool true \
            'Privileges' -bool true
    koopa_h2 'Mac App Store'
    # Enable the WebKit Developer Tools in the Mac App Store.
    "${app['defaults']}" write \
        'com.apple.appstore' \
        'WebKitDeveloperExtras' \
        -bool true
    # Enable Debug Menu in the Mac App Store.
    "${app['defaults']}" write \
        'com.apple.appstore' \
        'ShowDebugMenu' \
        -bool true
    # Enable the automatic update check.
    "${app['defaults']}" write \
        'com.apple.SoftwareUpdate' \
        'AutomaticCheckEnabled' \
        -bool true
    # Download newly available updates in background.
    "${app['defaults']}" write \
        'com.apple.SoftwareUpdate' \
        'AutomaticDownload' \
        -int 1
    # Install System data files & security updates.
    "${app['defaults']}" write \
        'com.apple.SoftwareUpdate' \
        'CriticalUpdateInstall' \
        -int 1
    # Automatically download apps purchased on other Macs.
    "${app['defaults']}" write \
        'com.apple.SoftwareUpdate' \
        'ConfigDataInstall' \
        -int 1
    # Turn on app auto-update.
    "${app['defaults']}" write \
        'com.apple.commerce' \
        'AutoUpdate' \
        -bool true
    # Allow the App Store to reboot machine on macOS updates.
    "${app['defaults']}" write \
        'com.apple.commerce' \
        'AutoUpdateRestartRequired' \
        -bool true
    # Check for software updates weekly.
    "${app['defaults']}" write \
        'com.apple.SoftwareUpdate' \
        'ScheduleFrequency' \
        -int 7
    koopa_h2 'Activity Monitor'
    # Show the main window when launching Activity Monitor.
    "${app['defaults']}" write \
        'com.apple.ActivityMonitor' \
        'OpenMainWindow' \
        -bool true
    # Visualize CPU usage in the Activity Monitor Dock icon.
    "${app['defaults']}" write \
        'com.apple.ActivityMonitor' \
        'IconType' \
        -int 5
    # Show all processes in Activity Monitor.
    "${app['defaults']}" write \
        'com.apple.ActivityMonitor' \
        'ShowCategory' \
        -int 0
    # Sort Activity Monitor results by CPU usage.
    "${app['defaults']}" write \
        'com.apple.ActivityMonitor' \
        'SortColumn' \
        -string 'CPUUsage'
    "${app['defaults']}" write \
        'com.apple.ActivityMonitor' \
        'SortDirection' \
        -int 0
    koopa_h2 'Disk Utility'
    # Enable the debug menu in Disk Utility.
    "${app['defaults']}" write \
        'com.apple.DiskUtility' \
        'DUDebugMenuEnabled' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.DiskUtility' \
        'advanced-image-options' \
        -bool true
    koopa_h2 'Time Machine'
    # Prevent Time Machine from prompting to use new hard drives as backup.
    "${app['defaults']}" write \
        'com.apple.TimeMachine' \
        'DoNotOfferNewDisksForBackup' \
        -bool true
    koopa_h2 'Safari'
    # Check the defaults with 'defaults read -app Safari'.
    # Privacy: don't send search queries to Apple.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'UniversalSearchEnabled' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'SuppressSearchSuggestions' \
        -bool true
    # Press Tab to highlight each item on a web page.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WebKitTabToLinksPreferenceKey' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks' \
        -bool true
    # Show the full URL in the address bar (note: this still hides the scheme).
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'ShowFullURLInSmartSearchField' \
        -bool true
    # Set Safari's home page to 'about:blank' for faster loading.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'HomePage' \
        -string 'about:blank'
    # Prevent Safari from opening 'safe' files automatically after downloading.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'AutoOpenSafeDownloads' \
        -bool false
    # Allow hitting the Backspace key to go to the previous page in history.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2BackspaceKeyNavigationEnabled" \
        -bool true
    # Hide Safari's bookmarks bar by default.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'ShowFavoritesBar' \
        -bool false
    # Hide Safari's sidebar in Top Sites.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'ShowSidebarInTopSites' \
        -bool false
    # Disable Safari's thumbnail cache for History and Top Sites.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'DebugSnapshotsUpdatePolicy' \
        -int 2
    # Enable Safari's debug menu.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'IncludeInternalDebugMenu' \
        -bool true
    # Make Safari's search banners default to Contains instead of Starts With.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'FindOnPageMatchesWordStartsOnly' \
        -bool false
    # Remove useless icons from Safari's bookmarks bar.
    # > defaults write \
    # >     'com.apple.Safari' \
    # >     'ProxiesInBookmarksBar' \
    # >     '()'
    # Enable the Develop menu and the Web Inspector in Safari.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'IncludeDevelopMenu' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WebKitDeveloperExtrasEnabledPreferenceKey' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2DeveloperExtrasEnabled" \
        -bool true
    # Add a context menu item for showing the Web Inspector in web views.
    "${app['defaults']}" write \
        'NSGlobalDomain' \
        'WebKitDeveloperExtras' \
        -bool true
    # Disable continuous spellchecking.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WebContinuousSpellCheckingEnabled' \
        -bool false
    # Disable auto-correct.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WebAutomaticSpellingCorrectionEnabled' \
        -bool false
    # Disable AutoFill.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'AutoFillFromAddressBook' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'AutoFillPasswords' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'AutoFillCreditCardData' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'AutoFillMiscellaneousForms' \
        -bool false
    # Warn about fraudulent websites.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WarnAboutFraudulentWebsites' \
        -bool true
    # Disable plug-ins.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WebKitPluginsEnabled' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled' \
        -bool false
    # Disable Java.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WebKitJavaEnabled' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2JavaEnabledForLocalFiles" \
        -bool false
    # Block pop-up windows.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WebKitJavaScriptCanOpenWindowsAutomatically' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2JavaScriptCanOpenWindowsAutomatically" \
        -bool false
    # Enable 'Do Not Track'.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'SendDoNotTrackHTTPHeader' \
        -bool true
    # Update extensions automatically.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'InstallExtensionUpdatesAutomatically' \
        -bool true
    # Disable auto-playing video.
    "${app['defaults']}" write \
        'com.apple.Safari' \
        'WebKitMediaPlaybackAllowsInline' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.SafariTechnologyPreview' \
        'WebKitMediaPlaybackAllowsInline' \
        -bool false
    "${app['defaults']}" write \
        'com.apple.Safari' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2AllowsInlineMediaPlayback" \
        -bool false
    "${app['defaults']}" write \
        'com.apple.SafariTechnologyPreview' \
        "com.apple.Safari.ContentPageGroupIdentifier.\
WebKit2AllowsInlineMediaPlayback" \
        -bool false
    koopa_h2 'Mail'
    # Disable send and reply animations in Mail.app.
    "${app['defaults']}" write \
        'com.apple.mail' \
        'DisableReplyAnimations' \
        -bool true
    "${app['defaults']}" write \
        'com.apple.mail' \
        'DisableSendAnimations' \
        -bool true
    # Copy email addresses as 'foo@example.com' instead of
    # 'Foo Bar <foo@example.com>' in Mail.app.
    "${app['defaults']}" write \
        'com.apple.mail' \
        'AddressesIncludeNameOnPasteboard' \
        -bool false
    # Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app.
    "${app['defaults']}" write \
        'com.apple.mail' \
        'NSUserKeyEquivalents' \
        -dict-add 'Send' '@\U21a9'
    # Display emails in threaded mode, sorted by date (oldest at the top).
    "${app['defaults']}" write \
        'com.apple.mail' \
        'DraftsViewerAttributes' \
        -dict-add 'DisplayInThreadedMode' -string 'yes'
    "${app['defaults']}" write \
        'com.apple.mail' \
        'DraftsViewerAttributes' \
        -dict-add 'SortedDescending' -string 'no'
    "${app['defaults']}" write \
        'com.apple.mail' \
        'DraftsViewerAttributes' \
        -dict-add 'SortOrder' -string 'received-date'
    # Disable inline attachments (just show the icons).
    "${app['defaults']}" write \
        'com.apple.mail' \
        'DisableInlineAttachmentViewing' \
        -bool true
    # Disable automatic spell checking.
    "${app['defaults']}" write \
        'com.apple.mail' \
        'SpellCheckingBehavior' \
        -string 'NoSpellCheckingEnabled'
    koopa_h2 'Terminal'
    # Only use UTF-8 in Terminal.app.
    "${app['defaults']}" write \
        'com.apple.terminal' \
        'StringEncodings' \
        -array 4
    # Enable Secure Keyboard Entry in Terminal.app.
    # See: https://security.stackexchange.com/a/47786/8918
    "${app['defaults']}" write \
        'com.apple.terminal' \
        'SecureKeyboardEntry' \
        -bool true
    # Disable the annoying line marks.
    "${app['defaults']}" write \
        'com.apple.Terminal' \
        'ShowLineMarks' \
        -int 0
    koopa_h2 'Messages'
    # Disable automatic emoji substitution (i.e. use plain text smileys).
    "${app['defaults']}" write \
        'com.apple.messageshelper.MessageController' \
        'SOInputLineSettings' \
        -dict-add 'automaticEmojiSubstitutionEnablediMessage' \
        -bool false
    # Disable smart quotes as it's annoying for messages that contain code.
    "${app['defaults']}" write \
        'com.apple.messageshelper.MessageController' \
        'SOInputLineSettings' \
        -dict-add 'automaticQuoteSubstitutionEnabled' \
        -bool false
    # Disable continuous spell checking.
    "${app['defaults']}" write \
        'com.apple.messageshelper.MessageController' \
        'SOInputLineSettings' \
        -dict-add 'continuousSpellCheckingEnabled' \
        -bool false
    koopa_h2 'Photos'
    # Prevent Photos from opening automatically when devices are plugged in.
    "${app['defaults']}" -currentHost write \
        'com.apple.ImageCapture' \
        'disableHotPlug' \
        -bool true
    koopa_h2 'TextEdit'
    # Use plain text mode for new TextEdit documents.
    "${app['defaults']}" write \
        'com.apple.TextEdit' \
        'RichText' \
        -int 0
    # Open and save files as UTF-8 in TextEdit.
    "${app['defaults']}" write \
        'com.apple.TextEdit' \
        'PlainTextEncoding' \
        -int 4
    "${app['defaults']}" write \
        'com.apple.TextEdit' \
        'PlainTextEncodingForWrite' \
        -int 4
    koopa_h2 'Google Chrome'
    # Disable the all too sensitive backswipe on trackpads.
    "${app['defaults']}" write \
        'com.google.Chrome' \
        'AppleEnableSwipeNavigateWithScrolls' \
        -bool false
    "${app['defaults']}" write \
        'com.google.Chrome.canary' \
        'AppleEnableSwipeNavigateWithScrolls' \
        -bool false
    # Disable the all too sensitive backswipe on Magic Mouse.
    "${app['defaults']}" write \
        'com.google.Chrome' \
        'AppleEnableMouseSwipeNavigateWithScrolls' \
        -bool false
    "${app['defaults']}" write \
        'com.google.Chrome.canary' \
        'AppleEnableMouseSwipeNavigateWithScrolls' \
        -bool false
    # Use the system-native print preview dialog.
    "${app['defaults']}" write \
        'com.google.Chrome' \
        'DisablePrintPreview' \
        -bool true
    "${app['defaults']}" write \
        'com.google.Chrome.canary' \
        'DisablePrintPreview' \
        -bool true
    # Expand the print dialog by default.
    "${app['defaults']}" write \
        'com.google.Chrome' \
        'PMPrintingExpandedStateForPrint2' \
        -bool true
    "${app['defaults']}" write \
        'com.google.Chrome.canary' \
        'PMPrintingExpandedStateForPrint2' \
        -bool true
    koopa_h2 'GPGMail'
    # Disable signing emails by default.
    "${app['defaults']}" write \
        "${HOME}/Library/Preferences/org.gpgtools.gpgmail" \
        'SignNewEmailsByDefault' \
        -bool false
    koopa_h2 'iTerm'
    # Don't display the annoying prompt when quitting iTerm.
    "${app['defaults']}" write \
        'com.googlecode.iterm2' \
        'PromptOnQuit' \
        -bool false
    koopa_h2 'BBEdit'
    # See also:
    # - https://www.barebones.com/support/bbedit/ExpertPreferences.html
    # - https://www.barebones.com/support/bbedit/zshenv.html
    # - https://www.barebones.com/support/bbedit/lsp-notes.html
    "${app['defaults']}" write \
        'com.barebones.bbedit' \
        'DisableCursorBlink' \
        -bool true
    "${app['defaults']}" write \
        'com.barebones.bbedit' \
        'UseFlakeForPythonSyntaxChecking' \
        -bool false
    "${app['defaults']}" write \
        'com.barebones.bbedit' \
        'WarnMalformedUTF8' \
        -bool true
    koopa_h2 'Final steps'
    # This step is CPU intensive and can cause the fans to kick on for old
    # Intel Macs, so disabling.
    # > koopa_alert "Removing duplicates in the 'Open With' menu."
    # See also 'lscleanup' alias.
    # > "${app['lsregister']}" \
    # >     -kill -r \
    # >     -domain 'local' \
    # >     -domain 'system' \
    # >     -domain 'user'
    # Kill affected apps.
    app_names=(
        # > 'Activity Monitor'
        # > 'Disk Utility'
        # > 'GPGMail'
        # > 'Google Chrome'
        # > 'Mail'
        # > 'Messages'
        # > 'Photos'
        # > 'Safari'
        # > 'Terminal'
        # > 'Time Machine'
        # > 'Tweetbot'
        # > 'iTerm'
        'Dock'
        'Finder'
        'SystemUIServer'
        'cfprefsd'
    )
    koopa_alert "Reloading affected apps: $(koopa_to_string "${app_names[@]}")"
    for app_name in "${app_names[@]}"
    do
        "${app['kill_all']}" "${app_name}" &>/dev/null || true
    done
    return 0
}
