"""Configure macOS user preferences."""

from __future__ import annotations

import os
import subprocess
import sys


def main(
    *,
    name: str,
    platform: str,
    mode: str,
    verbose: bool = False,
) -> None:
    """Configure macOS user defaults.

    Data-driven approach: all `defaults write` calls are stored as tuples
    and iterated over for clean, maintainable code.
    """
    if sys.platform != "darwin":
        msg = "macOS only."
        raise RuntimeError(msg)
    defaults = "/usr/bin/defaults"
    killall = "/usr/bin/killall"
    chflags = "/usr/bin/chflags"
    plistbuddy = "/usr/libexec/PlistBuddy"
    home = os.path.expanduser("~")
    screenshots_dir = os.path.join(home, "Pictures", "screenshots")
    os.makedirs(screenshots_dir, exist_ok=True)
    # Standard defaults write entries: (domain, key, type_flag, value)
    writes: list[tuple[str, str, str, str]] = [
        # General UI/UX
        (
            "com.apple.WindowManager",
            "EnableStandardClickToShowDesktop",
            "-bool",
            "false",
        ),
        ("com.apple.universalaccess", "reduceMotion", "-bool", "true"),
        ("com.apple.universalaccess", "reduceTransparency", "-bool", "true"),
        (
            "com.apple.universalaccess",
            "differentiateWithoutColor",
            "-bool",
            "true",
        ),
        # Sidebar icon size.
        ("NSGlobalDomain", "NSTableViewDefaultSizeMode", "-int", "2"),
        # Scrollbar appearance.
        ("NSGlobalDomain", "AppleShowScrollBars", "-string", "Automatic"),
        # Disable animated focus ring.
        ("NSGlobalDomain", "NSUseAnimatedFocusRing", "-bool", "false"),
        # Expand save panel by default.
        (
            "NSGlobalDomain",
            "NSNavPanelExpandedStateForSaveMode",
            "-bool",
            "true",
        ),
        (
            "NSGlobalDomain",
            "NSNavPanelExpandedStateForSaveMode2",
            "-bool",
            "true",
        ),
        # Expand print panel by default.
        (
            "NSGlobalDomain",
            "PMPrintingExpandedStateForPrint",
            "-bool",
            "true",
        ),
        (
            "NSGlobalDomain",
            "PMPrintingExpandedStateForPrint2",
            "-bool",
            "true",
        ),
        # Save to disk (not iCloud) by default.
        (
            "NSGlobalDomain",
            "NSDocumentSaveNewDocumentsToCloud",
            "-bool",
            "false",
        ),
        # Quit printer app when print jobs complete.
        (
            "com.apple.print.PrintingPrefs",
            "Quit When Finished",
            "-bool",
            "true",
        ),
        # Disable 'Are you sure you want to open this application?' dialog.
        ("com.apple.LaunchServices", "LSQuarantine", "-bool", "false"),
        # Disable resume system-wide.
        (
            "com.apple.systempreferences",
            "NSQuitAlwaysKeepsWindows",
            "-bool",
            "false",
        ),
        # Disable automatic termination of inactive apps.
        (
            "NSGlobalDomain",
            "NSDisableAutomaticTermination",
            "-bool",
            "true",
        ),
        # Set Help Viewer windows to non-floating mode.
        ("com.apple.helpviewer", "DevMode", "-bool", "true"),
        # Disable automatic capitalization.
        (
            "NSGlobalDomain",
            "NSAutomaticCapitalizationEnabled",
            "-bool",
            "false",
        ),
        # Disable smart dashes.
        (
            "NSGlobalDomain",
            "NSAutomaticDashSubstitutionEnabled",
            "-bool",
            "false",
        ),
        # Disable automatic period substitution.
        (
            "NSGlobalDomain",
            "NSAutomaticPeriodSubstitutionEnabled",
            "-bool",
            "false",
        ),
        # Disable smart quotes.
        (
            "NSGlobalDomain",
            "NSAutomaticQuoteSubstitutionEnabled",
            "-bool",
            "false",
        ),
        # Disable auto-correct.
        (
            "NSGlobalDomain",
            "NSAutomaticSpellingCorrectionEnabled",
            "-bool",
            "false",
        ),
        # Increase window resize speed for Cocoa applications.
        ("NSGlobalDomain", "NSWindowResizeTime", "-float", ".001"),
        # Dock, Dashboard, and hot corners.
        # Enable highlight hover effect for grid view of a stack.
        ("com.apple.dock", "mouse-over-hilite-stack", "-bool", "true"),
        # Set Dock icon size to 36 pixels.
        ("com.apple.dock", "tilesize", "-int", "36"),
        # Change minimize/maximize window effect.
        ("com.apple.dock", "mineffect", "-string", "scale"),
        # Minimize windows into their application's icon.
        ("com.apple.dock", "minimize-to-application", "-bool", "true"),
        # Disable spring loading for all Dock items.
        (
            "com.apple.dock",
            "enable-spring-load-actions-on-all-items",
            "-bool",
            "false",
        ),
        # Show indicator lights for open applications.
        ("com.apple.dock", "show-process-indicators", "-bool", "true"),
        # Don't animate opening applications from the Dock.
        ("com.apple.dock", "launchanim", "-bool", "false"),
        # Speed up Mission Control animations.
        ("com.apple.dock", "expose-animation-duration", "-float", "0.1"),
        # Don't group windows by application in Mission Control.
        ("com.apple.dock", "expose-group-by-app", "-bool", "false"),
        # Disable Dashboard.
        ("com.apple.dashboard", "mcx-disabled", "-bool", "true"),
        # Don't show Dashboard as a Space.
        ("com.apple.dock", "dashboard-in-overlay", "-bool", "true"),
        # Don't automatically rearrange Spaces based on most recent use.
        ("com.apple.dock", "mru-spaces", "-bool", "false"),
        # Remove the auto-hiding Dock delay.
        ("com.apple.dock", "autohide-delay", "-float", "0"),
        # Remove animation when hiding/showing the Dock.
        ("com.apple.dock", "autohide-time-modifier", "-float", "0"),
        # Automatically hide and show the Dock.
        ("com.apple.dock", "autohide", "-bool", "true"),
        # Make Dock icons of hidden applications translucent.
        ("com.apple.dock", "showhidden", "-bool", "true"),
        # Don't show recent applications in Dock.
        ("com.apple.dock", "show-recents", "-bool", "false"),
        # Disable the Launchpad gesture.
        ("com.apple.dock", "showLaunchpadGestureEnabled", "-int", "0"),
        # Hot corners.
        # Top left: None.
        ("com.apple.dock", "wvous-tl-corner", "-int", "0"),
        ("com.apple.dock", "wvous-tl-modifier", "-int", "0"),
        # Top right: Lock Screen.
        ("com.apple.dock", "wvous-tr-corner", "-int", "13"),
        ("com.apple.dock", "wvous-tr-modifier", "-int", "0"),
        # Bottom left: None.
        ("com.apple.dock", "wvous-bl-corner", "-int", "0"),
        ("com.apple.dock", "wvous-bl-modifier", "-int", "0"),
        # Bottom right: None.
        ("com.apple.dock", "wvous-br-corner", "-int", "0"),
        ("com.apple.dock", "wvous-br-modifier", "-int", "0"),
        # Trackpad: AppleMultitouchTrackpad.
        ("com.apple.AppleMultitouchTrackpad", "ActuateDetents", "-int", "0"),
        (
            "com.apple.AppleMultitouchTrackpad",
            "ActuationStrength",
            "-int",
            "0",
        ),
        ("com.apple.AppleMultitouchTrackpad", "Clicking", "-int", "1"),
        ("com.apple.AppleMultitouchTrackpad", "DragLock", "-int", "0"),
        ("com.apple.AppleMultitouchTrackpad", "Dragging", "-int", "0"),
        (
            "com.apple.AppleMultitouchTrackpad",
            "FirstClickThreshold",
            "-int",
            "0",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "ForceSuppressed",
            "-int",
            "1",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "SecondClickThreshold",
            "-int",
            "0",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadCornerSecondaryClick",
            "-int",
            "0",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadFiveFingerPinchGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadFourFingerHorizSwipeGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadFourFingerPinchGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadFourFingerVertSwipeGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadHandResting",
            "-int",
            "1",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadHorizScroll",
            "-int",
            "1",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadMomentumScroll",
            "-int",
            "1",
        ),
        ("com.apple.AppleMultitouchTrackpad", "TrackpadPinch", "-int", "1"),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadRightClick",
            "-int",
            "1",
        ),
        ("com.apple.AppleMultitouchTrackpad", "TrackpadRotate", "-int", "1"),
        ("com.apple.AppleMultitouchTrackpad", "TrackpadScroll", "-int", "1"),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadThreeFingerDrag",
            "-int",
            "1",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadThreeFingerHorizSwipeGesture",
            "-int",
            "0",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadThreeFingerTapGesture",
            "-int",
            "0",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadThreeFingerVertSwipeGesture",
            "-int",
            "0",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadTwoFingerDoubleTapGesture",
            "-int",
            "1",
        ),
        (
            "com.apple.AppleMultitouchTrackpad",
            "TrackpadTwoFingerFromRightEdgeSwipeGesture",
            "-int",
            "3",
        ),
        # Bluetooth trackpad.
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "Clicking",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "DragLock",
            "-int",
            "0",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "Dragging",
            "-int",
            "0",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadCornerSecondaryClick",
            "-int",
            "2",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadFiveFingerPinchGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadFourFingerHorizSwipeGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadFourFingerPinchGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadFourFingerVertSwipeGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadHandResting",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadHorizScroll",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadMomentumScroll",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadPinch",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadRightClick",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadRotate",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadScroll",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadThreeFingerDrag",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadThreeFingerHorizSwipeGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadThreeFingerTapGesture",
            "-int",
            "0",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadThreeFingerVertSwipeGesture",
            "-int",
            "2",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadTwoFingerDoubleTapGesture",
            "-int",
            "1",
        ),
        (
            "com.apple.driver.AppleBluetoothMultitouch.trackpad",
            "TrackpadTwoFingerFromRightEdgeSwipeGesture",
            "-int",
            "3",
        ),
        # Keyboard: tap to click.
        ("NSGlobalDomain", "com.apple.mouse.tapBehavior", "-int", "1"),
        # Natural scroll direction.
        ("NSGlobalDomain", "com.apple.swipescrolldirection", "-bool", "true"),
        # Full keyboard access for all controls.
        ("NSGlobalDomain", "AppleKeyboardUIMode", "-int", "3"),
        # Follow keyboard focus while zoomed in.
        (
            "com.apple.universalaccess",
            "closeViewZoomFollowsFocus",
            "-bool",
            "true",
        ),
        # Enable press-and-hold for accent marks.
        ("NSGlobalDomain", "ApplePressAndHoldEnabled", "-bool", "true"),
        # Locale settings.
        ("NSGlobalDomain", "AppleLocale", "-string", "en_US@currency=USD"),
        ("NSGlobalDomain", "AppleMeasurementUnits", "-string", "Centimeters"),
        ("NSGlobalDomain", "AppleMetricUnits", "-bool", "true"),
        # Screen: password after screensaver.
        ("com.apple.screensaver", "askForPassword", "-int", "1"),
        ("com.apple.screensaver", "askForPasswordDelay", "-int", "0"),
        # Font smoothing.
        ("NSGlobalDomain", "AppleFontSmoothing", "-int", "0"),
        # Screenshots.
        ("com.apple.screencapture", "name", "-string", "Screenshot"),
        ("com.apple.screencapture", "include-date", "-bool", "true"),
        ("com.apple.screencapture", "location", "-string", screenshots_dir),
        ("com.apple.screencapture", "type", "-string", "png"),
        ("com.apple.screencapture", "showsCursor", "-bool", "false"),
        ("com.apple.screencapture", "disable-shadow", "-bool", "true"),
        ("com.apple.screencapture", "show-thumbnail", "-bool", "false"),
        # Finder.
        ("com.apple.finder", "NewWindowTarget", "-string", "PfLo"),
        (
            "com.apple.finder",
            "NewWindowTargetPath",
            "-string",
            f"file://{home}/Documents/",
        ),
        ("com.apple.finder", "DisableAllAnimations", "-bool", "true"),
        (
            "com.apple.finder",
            "ShowExternalHardDrivesOnDesktop",
            "-bool",
            "true",
        ),
        ("com.apple.finder", "ShowHardDrivesOnDesktop", "-bool", "true"),
        (
            "com.apple.finder",
            "ShowMountedServersOnDesktop",
            "-bool",
            "true",
        ),
        (
            "com.apple.finder",
            "ShowRemovableMediaOnDesktop",
            "-bool",
            "true",
        ),
        ("NSGlobalDomain", "AppleShowAllExtensions", "-bool", "true"),
        ("com.apple.finder", "ShowStatusBar", "-bool", "true"),
        ("com.apple.finder", "ShowPathbar", "-bool", "true"),
        ("com.apple.finder", "_FXShowPosixPathInTitle", "-bool", "false"),
        ("com.apple.finder", "_FXSortFoldersFirst", "-bool", "true"),
        ("com.apple.finder", "FXDefaultSearchScope", "-string", "SCcf"),
        (
            "com.apple.finder",
            "FXEnableExtensionChangeWarning",
            "-bool",
            "false",
        ),
        ("NSGlobalDomain", "com.apple.springing.enabled", "-bool", "false"),
        ("NSGlobalDomain", "com.apple.springing.delay", "-float", "0"),
        (
            "com.apple.desktopservices",
            "DSDontWriteNetworkStores",
            "-bool",
            "true",
        ),
        (
            "com.apple.desktopservices",
            "DSDontWriteUSBStores",
            "-bool",
            "true",
        ),
        # Finder view: list view.
        ("com.apple.finder", "FXPreferredViewStyle", "-string", "Nlsv"),
        # Disable warning before emptying Trash.
        ("com.apple.finder", "WarnOnEmptyTrash", "-bool", "false"),
        # Enable AirDrop over Ethernet.
        (
            "com.apple.NetworkBrowser",
            "BrowseAllInterfaces",
            "-bool",
            "true",
        ),
        # Mac App Store.
        ("com.apple.appstore", "WebKitDeveloperExtras", "-bool", "true"),
        ("com.apple.appstore", "ShowDebugMenu", "-bool", "true"),
        (
            "com.apple.SoftwareUpdate",
            "AutomaticCheckEnabled",
            "-bool",
            "true",
        ),
        ("com.apple.SoftwareUpdate", "AutomaticDownload", "-int", "1"),
        ("com.apple.SoftwareUpdate", "CriticalUpdateInstall", "-int", "1"),
        ("com.apple.SoftwareUpdate", "ConfigDataInstall", "-int", "1"),
        ("com.apple.commerce", "AutoUpdate", "-bool", "true"),
        (
            "com.apple.commerce",
            "AutoUpdateRestartRequired",
            "-bool",
            "true",
        ),
        ("com.apple.SoftwareUpdate", "ScheduleFrequency", "-int", "1"),
        # Activity Monitor.
        ("com.apple.ActivityMonitor", "OpenMainWindow", "-bool", "true"),
        ("com.apple.ActivityMonitor", "IconType", "-int", "5"),
        ("com.apple.ActivityMonitor", "ShowCategory", "-int", "0"),
        (
            "com.apple.ActivityMonitor",
            "SortColumn",
            "-string",
            "CPUUsage",
        ),
        ("com.apple.ActivityMonitor", "SortDirection", "-int", "0"),
        # Disk Utility.
        ("com.apple.DiskUtility", "DUDebugMenuEnabled", "-bool", "true"),
        ("com.apple.DiskUtility", "advanced-image-options", "-bool", "true"),
        # Time Machine.
        (
            "com.apple.TimeMachine",
            "DoNotOfferNewDisksForBackup",
            "-bool",
            "true",
        ),
        # Safari.
        ("com.apple.Safari", "UniversalSearchEnabled", "-bool", "false"),
        ("com.apple.Safari", "SuppressSearchSuggestions", "-bool", "true"),
        (
            "com.apple.Safari",
            "WebKitTabToLinksPreferenceKey",
            "-bool",
            "true",
        ),
        (
            "com.apple.Safari",
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks",
            "-bool",
            "true",
        ),
        (
            "com.apple.Safari",
            "ShowFullURLInSmartSearchField",
            "-bool",
            "true",
        ),
        ("com.apple.Safari", "HomePage", "-string", "about:blank"),
        ("com.apple.Safari", "AutoOpenSafeDownloads", "-bool", "false"),
        (
            "com.apple.Safari",
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled",
            "-bool",
            "true",
        ),
        ("com.apple.Safari", "ShowFavoritesBar", "-bool", "false"),
        ("com.apple.Safari", "ShowSidebarInTopSites", "-bool", "false"),
        ("com.apple.Safari", "DebugSnapshotsUpdatePolicy", "-int", "2"),
        ("com.apple.Safari", "IncludeInternalDebugMenu", "-bool", "true"),
        (
            "com.apple.Safari",
            "FindOnPageMatchesWordStartsOnly",
            "-bool",
            "false",
        ),
        ("com.apple.Safari", "IncludeDevelopMenu", "-bool", "true"),
        (
            "com.apple.Safari",
            "WebKitDeveloperExtrasEnabledPreferenceKey",
            "-bool",
            "true",
        ),
        (
            "com.apple.Safari",
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled",
            "-bool",
            "true",
        ),
        ("NSGlobalDomain", "WebKitDeveloperExtras", "-bool", "true"),
        (
            "com.apple.Safari",
            "WebContinuousSpellCheckingEnabled",
            "-bool",
            "false",
        ),
        (
            "com.apple.Safari",
            "WebAutomaticSpellingCorrectionEnabled",
            "-bool",
            "false",
        ),
        ("com.apple.Safari", "AutoFillFromAddressBook", "-bool", "false"),
        ("com.apple.Safari", "AutoFillPasswords", "-bool", "false"),
        ("com.apple.Safari", "AutoFillCreditCardData", "-bool", "false"),
        ("com.apple.Safari", "AutoFillMiscellaneousForms", "-bool", "false"),
        (
            "com.apple.Safari",
            "WarnAboutFraudulentWebsites",
            "-bool",
            "true",
        ),
        ("com.apple.Safari", "WebKitPluginsEnabled", "-bool", "false"),
        (
            "com.apple.Safari",
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled",
            "-bool",
            "false",
        ),
        ("com.apple.Safari", "WebKitJavaEnabled", "-bool", "false"),
        (
            "com.apple.Safari",
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled",
            "-bool",
            "false",
        ),
        (
            "com.apple.Safari",
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles",
            "-bool",
            "false",
        ),
        (
            "com.apple.Safari",
            "WebKitJavaScriptCanOpenWindowsAutomatically",
            "-bool",
            "false",
        ),
        (
            "com.apple.Safari",
            "com.apple.Safari.ContentPageGroupIdentifier"
            ".WebKit2JavaScriptCanOpenWindowsAutomatically",
            "-bool",
            "false",
        ),
        ("com.apple.Safari", "SendDoNotTrackHTTPHeader", "-bool", "true"),
        (
            "com.apple.Safari",
            "InstallExtensionUpdatesAutomatically",
            "-bool",
            "true",
        ),
        (
            "com.apple.Safari",
            "WebKitMediaPlaybackAllowsInline",
            "-bool",
            "false",
        ),
        (
            "com.apple.SafariTechnologyPreview",
            "WebKitMediaPlaybackAllowsInline",
            "-bool",
            "false",
        ),
        (
            "com.apple.Safari",
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback",
            "-bool",
            "false",
        ),
        (
            "com.apple.SafariTechnologyPreview",
            "com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback",
            "-bool",
            "false",
        ),
        # Mail.
        ("com.apple.mail", "DisableReplyAnimations", "-bool", "true"),
        ("com.apple.mail", "DisableSendAnimations", "-bool", "true"),
        (
            "com.apple.mail",
            "AddressesIncludeNameOnPasteboard",
            "-bool",
            "false",
        ),
        (
            "com.apple.mail",
            "DisableInlineAttachmentViewing",
            "-bool",
            "true",
        ),
        (
            "com.apple.mail",
            "SpellCheckingBehavior",
            "-string",
            "NoSpellCheckingEnabled",
        ),
        # Terminal.
        ("com.apple.terminal", "SecureKeyboardEntry", "-bool", "true"),
        ("com.apple.Terminal", "ShowLineMarks", "-int", "0"),
        # Preview.
        (
            "com.apple.Preview",
            "PVPDFSuppressSidebarOnOpening",
            "-bool",
            "true",
        ),
        # TextEdit.
        ("com.apple.TextEdit", "RichText", "-int", "0"),
        ("com.apple.TextEdit", "PlainTextEncoding", "-int", "4"),
        ("com.apple.TextEdit", "PlainTextEncodingForWrite", "-int", "4"),
        # Google Chrome.
        (
            "com.google.Chrome",
            "AppleEnableSwipeNavigateWithScrolls",
            "-bool",
            "false",
        ),
        (
            "com.google.Chrome.canary",
            "AppleEnableSwipeNavigateWithScrolls",
            "-bool",
            "false",
        ),
        (
            "com.google.Chrome",
            "AppleEnableMouseSwipeNavigateWithScrolls",
            "-bool",
            "false",
        ),
        (
            "com.google.Chrome.canary",
            "AppleEnableMouseSwipeNavigateWithScrolls",
            "-bool",
            "false",
        ),
        ("com.google.Chrome", "DisablePrintPreview", "-bool", "true"),
        (
            "com.google.Chrome.canary",
            "DisablePrintPreview",
            "-bool",
            "true",
        ),
        (
            "com.google.Chrome",
            "PMPrintingExpandedStateForPrint2",
            "-bool",
            "true",
        ),
        (
            "com.google.Chrome.canary",
            "PMPrintingExpandedStateForPrint2",
            "-bool",
            "true",
        ),
        # GPGMail.
        (
            f"{home}/Library/Preferences/org.gpgtools.gpgmail",
            "SignNewEmailsByDefault",
            "-bool",
            "false",
        ),
        # iTerm.
        ("com.googlecode.iterm2", "PromptOnQuit", "-bool", "false"),
        # BBEdit.
        ("com.barebones.bbedit", "DisableCursorBlink", "-bool", "true"),
        (
            "com.barebones.bbedit",
            "UseFlakeForPythonSyntaxChecking",
            "-bool",
            "false",
        ),
        ("com.barebones.bbedit", "WarnMalformedUTF8", "-bool", "true"),
    ]
    for domain, key, type_flag, value in writes:
        subprocess.run(
            [defaults, "write", domain, key, type_flag, value],
            check=True,
        )
    # Global domain writes using -globalDomain: (key, type_flag, value)
    global_domain_writes: list[tuple[str, str, str]] = [
        ("AppleInterfaceStyle", "-string", "Dark"),
    ]
    for key, type_flag, value in global_domain_writes:
        subprocess.run(
            [defaults, "write", "-globalDomain", key, type_flag, value],
            check=True,
        )
    # Writes using -g (global): (key, type_flag, value)
    g_writes: list[tuple[str, str, str]] = [
        ("com.apple.mouse.scaling", "-float", "2.0"),
        ("com.apple.trackpad.scaling", "-float", "2.0"),
        ("InitialKeyRepeat", "-int", "15"),
        ("KeyRepeat", "-int", "2"),
    ]
    for key, type_flag, value in g_writes:
        subprocess.run(
            [defaults, "write", "-g", key, type_flag, value],
            check=True,
        )
    # -currentHost write entries: (domain, key, type_flag, value)
    current_host_writes: list[tuple[str, str, str, str]] = [
        (
            "com.apple.coreservices.useractivityd",
            "ActivityAdvertisingAllowed",
            "-bool",
            "false",
        ),
        (
            "com.apple.coreservices.useractivityd",
            "ActivityReceivingAllowed",
            "-bool",
            "false",
        ),
        # Enable secondary click.
        (
            "NSGlobalDomain",
            "com.apple.trackpad.enableSecondaryClick",
            "-bool",
            "true",
        ),
        # Enable tap to click.
        ("NSGlobalDomain", "com.apple.mouse.tapBehavior", "-int", "1"),
        # Map bottom right corner to right-click.
        (
            "NSGlobalDomain",
            "com.apple.trackpad.trackpadCornerClickBehavior",
            "-int",
            "1",
        ),
        # Photos: prevent auto-opening.
        ("com.apple.ImageCapture", "disableHotPlug", "-bool", "true"),
    ]
    for domain, key, type_flag, value in current_host_writes:
        subprocess.run(
            [defaults, "-currentHost", "write", domain, key, type_flag, value],
            check=True,
        )
    # -currentHost write -g entries: (key, type_flag, value)
    current_host_g_writes: list[tuple[str, str, str]] = [
        ("com.apple.trackpad.threeFingerTapGesture", "-int", "0"),
    ]
    for key, type_flag, value in current_host_g_writes:
        subprocess.run(
            [defaults, "-currentHost", "write", "-g", key, type_flag, value],
            check=True,
        )
    # Terminal.app StringEncodings (array type, handled separately).
    subprocess.run(
        [defaults, "write", "com.apple.terminal", "StringEncodings", "-array", "4"],
        check=True,
    )
    # Mail: NSUserKeyEquivalents dict-add.
    subprocess.run(
        [
            defaults,
            "write",
            "com.apple.mail",
            "NSUserKeyEquivalents",
            "-dict-add",
            "Send",
            r"@\U21a9",
        ],
        check=True,
    )
    # Mail: DraftsViewerAttributes dict-add entries.
    subprocess.run(
        [
            defaults,
            "write",
            "com.apple.mail",
            "DraftsViewerAttributes",
            "-dict-add",
            "DisplayInThreadedMode",
            "-string",
            "yes",
        ],
        check=True,
    )
    subprocess.run(
        [
            defaults,
            "write",
            "com.apple.mail",
            "DraftsViewerAttributes",
            "-dict-add",
            "SortedDescending",
            "-string",
            "no",
        ],
        check=True,
    )
    subprocess.run(
        [
            defaults,
            "write",
            "com.apple.mail",
            "DraftsViewerAttributes",
            "-dict-add",
            "SortOrder",
            "-string",
            "received-date",
        ],
        check=True,
    )
    # Messages: SOInputLineSettings dict-add entries.
    subprocess.run(
        [
            defaults,
            "write",
            "com.apple.messageshelper.MessageController",
            "SOInputLineSettings",
            "-dict-add",
            "automaticEmojiSubstitutionEnablediMessage",
            "-bool",
            "false",
        ],
        check=True,
    )
    subprocess.run(
        [
            defaults,
            "write",
            "com.apple.messageshelper.MessageController",
            "SOInputLineSettings",
            "-dict-add",
            "automaticQuoteSubstitutionEnabled",
            "-bool",
            "false",
        ],
        check=True,
    )
    subprocess.run(
        [
            defaults,
            "write",
            "com.apple.messageshelper.MessageController",
            "SOInputLineSettings",
            "-dict-add",
            "continuousSpellCheckingEnabled",
            "-bool",
            "false",
        ],
        check=True,
    )
    # Finder: FXInfoPanesExpanded dict.
    subprocess.run(
        [
            defaults,
            "write",
            "com.apple.finder",
            "FXInfoPanesExpanded",
            "-dict",
            "General",
            "-bool",
            "true",
            "OpenWith",
            "-bool",
            "true",
            "Privileges",
            "-bool",
            "true",
        ],
        check=True,
    )
    # PlistBuddy commands for Finder icon view settings.
    finder_plist = os.path.join(home, "Library", "Preferences", "com.apple.finder.plist")
    plistbuddy_commands: list[str] = [
        "Set :DesktopViewSettings:IconViewSettings:showItemInfo true",
        "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true",
        "Set :StandardViewSettings:IconViewSettings:showItemInfo true",
        "Set DesktopViewSettings:IconViewSettings:labelOnBottom false",
        "Set :DesktopViewSettings:IconViewSettings:arrangeBy name",
        "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy name",
        "Set :StandardViewSettings:IconViewSettings:arrangeBy name",
        "Set :DesktopViewSettings:IconViewSettings:gridSpacing 100",
        "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 100",
        "Set :StandardViewSettings:IconViewSettings:gridSpacing 100",
        "Set :DesktopViewSettings:IconViewSettings:iconSize 48",
        "Set :FK_StandardViewSettings:IconViewSettings:iconSize 48",
        "Set :StandardViewSettings:IconViewSettings:iconSize 48",
    ]
    for cmd in plistbuddy_commands:
        subprocess.run(
            [plistbuddy, "-c", cmd, finder_plist],
            check=False,
        )
    # Show ~/Library folder.
    subprocess.run([chflags, "nohidden", os.path.join(home, "Library")])
    # Kill affected apps.
    for app_name in ("Dock", "Finder", "SystemUIServer", "cfprefsd"):
        subprocess.run(
            [killall, app_name],
            capture_output=True,
            check=False,
        )
