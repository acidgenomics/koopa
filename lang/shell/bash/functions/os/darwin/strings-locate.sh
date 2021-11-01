#!/usr/bin/env bash

# FIXME Rename all functions to include 'macos' prefix.

koopa::locate_automount() { # {{{1
    # """
    # Locate macOS automount.
    # @note Updated 2021-10-27.
    # """
    koopa:::locate_app '/usr/sbin/automount'
}

koopa::locate_defaults() { # {{{1
    # """
    # Locate macOS defaults.
    # @note Updated 2021-10-31.
    # """
    koopa:::locate_app '/usr/bin/defaults'
}

koopa::locate_diskutil() { # {{{1
    # """
    # Locate macOS diskutil.
    # @note Updated 2021-10-29.
    # """
    koopa:::locate_app '/usr/sbin/diskutil'
}

koopa::locate_dscacheutil() { # {{{1
    # """
    # Locate macOS dscacheutil.
    # @note Updated 2021-10-27.
    # """
    koopa:::locate_app '/usr/bin/dscacheutil'
}

koopa::locate_hdiutil() { # {{{1
    # """
    # Locate macOS hdiutil.
    # @note Updated 2021-10-27.
    # """
    koopa:::locate_app '/usr/bin/hdiutil'
}

koopa::locate_installer() { # {{{1
    # """
    # Locate macOS installer.
    # @note Updated 2021-10-30.
    # """
    koopa:::locate_app '/usr/sbin/installer'
}

koopa::locate_kill_all() { # {{{1
    # """
    # Locate macOS killAll.
    # @note Updated 2021-10-27.
    # """
    koopa:::locate_app '/usr/bin/killAll'
}

koopa::locate_launchctl() { # {{{1
    # """
    # Locate macOS launchctl.
    # @note Updated 2021-10-29.
    # """
    koopa:::locate_app '/bin/launchctl'
}

koopa::locate_lsregister() { # {{{1
    # """
    # Locate macOS lsregister.
    # @note Updated 2021-10-27.
    # """
    koopa:::locate_app "/System/Library/Frameworks/CoreServices.framework\
/Frameworks/LaunchServices.framework/Support/lsregister"
}

koopa::locate_mas() { # {{{1
    # """
    # Locate macOS mas (Mac App Store).
    # @note Updated 2021-10-30.
    # """
    koopa:::locate_app 'mas'
}

koopa::locate_nvram() { # {{{1
    # """
    # Locate macOS nvram.
    # @note Updated 2021-10-31.
    # """
    koopa:::locate_app '/usr/sbin/nvram'
}

koopa::locate_open() { # {{{1
    # """
    # Locate macOS open command.
    # @note Updated 2021-10-27.
    # """
    koopa:::locate_app '/usr/bin/open'
}

koopa::locate_pkgutil() { # {{{1
    # """
    # Locate macOS pkgutil.
    # @note Updated 2021-10-26.
    # """
    koopa:::locate_app '/usr/sbin/pkgutil'
}

koopa::locate_plistbuddy() { # {{{1
    # """
    # Locate macOS PlistBuddy.
    # @note Updated 2021-10-31.
    # """
    koopa:::locate_app '/usr/libexec/PlistBuddy'
}

koopa::locate_plutil() { # {{{1
    # """
    # Locate macOS plutil.
    # @note Updated 2021-10-27.
    # """
    koopa:::locate_app '/usr/bin/plutil'
}

koopa::locate_pmset() { # {{{1
    # """
    # Locate macOS pmset.
    # @note Updated 2021-10-31.
    # """
    koopa:::locate_app '/usr/bin/pmset'
}

koopa::locate_reboot() { # {{{1
    # """
    # Locate macOS reboot.
    # @note Updated 2021-10-29.
    # """
    koopa:::locate_app '/sbin/reboot'
}

koopa::locate_scutil() { # {{{1
    # """
    # Locate macOS scutil.
    # @note Updated 2021-10-31.
    # """
    koopa:::locate_app '/usr/sbin/scutil'
}

koopa::locate_softwareupdate() { # {{{1
    # """
    # Locate macOS softwareupdate.
    # @note Updated 2021-10-30.
    # """
    koopa:::locate_app '/usr/sbin/automount'
}

koopa::locate_xattr() { # {{{1
    # """
    # Locate macOS xattr.
    # @note Updated 2021-10-27.
    # """
    koopa:::locate_app '/usr/bin/xattr'
}

koopa::locate_xcode_select() { # {{{1
    # """
    # Locate macOS xcode-select.
    # @note Updated 2021-10-30.
    # """
    koopa:::locate_app '/usr/bin/xcode-select'
}

koopa::locate_xcodebuild() { # {{{1
    # """
    # Locate macOS xcodebuild.
    # @note Updated 2021-10-30.
    # """
    koopa:::locate_app '/usr/bin/xcodebuild'
}
