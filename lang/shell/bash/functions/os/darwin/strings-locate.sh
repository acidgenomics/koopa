#!/usr/bin/env bash

koopa::macos_locate_automount() { # {{{1
    # """
    # Locate macOS automount.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/sbin/automount'
}

koopa::macos_locate_defaults() { # {{{1
    # """
    # Locate macOS defaults.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/defaults'
}

koopa::macos_locate_diskutil() { # {{{1
    # """
    # Locate macOS diskutil.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/sbin/diskutil'
}

koopa::macos_locate_dscacheutil() { # {{{1
    # """
    # Locate macOS dscacheutil.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/dscacheutil'
}

koopa::macos_locate_hdiutil() { # {{{1
    # """
    # Locate macOS hdiutil.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/hdiutil'
}

koopa::macos_locate_installer() { # {{{1
    # """
    # Locate macOS installer.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/sbin/installer'
}

koopa::macos_locate_kill_all() { # {{{1
    # """
    # Locate macOS killAll.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/killAll'
}

koopa::macos_locate_launchctl() { # {{{1
    # """
    # Locate macOS launchctl.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/bin/launchctl'
}

koopa::macos_locate_lsregister() { # {{{1
    # """
    # Locate macOS lsregister.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app "/System/Library/Frameworks/CoreServices.framework\
/Frameworks/LaunchServices.framework/Support/lsregister"
}

koopa::macos_locate_mas() { # {{{1
    # """
    # Locate macOS mas (Mac App Store).
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app 'mas'
}

koopa::macos_locate_nvram() { # {{{1
    # """
    # Locate macOS nvram.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/sbin/nvram'
}

koopa::macos_locate_open() { # {{{1
    # """
    # Locate macOS open command.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/open'
}

koopa::macos_locate_pkgutil() { # {{{1
    # """
    # Locate macOS pkgutil.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/sbin/pkgutil'
}

koopa::macos_locate_plistbuddy() { # {{{1
    # """
    # Locate macOS PlistBuddy.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/libexec/PlistBuddy'
}

koopa::macos_locate_plutil() { # {{{1
    # """
    # Locate macOS plutil.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/plutil'
}

koopa::macos_locate_pmset() { # {{{1
    # """
    # Locate macOS pmset.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/pmset'
}

koopa::macos_locate_reboot() { # {{{1
    # """
    # Locate macOS reboot.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/sbin/reboot'
}

koopa::macos_locate_scutil() { # {{{1
    # """
    # Locate macOS scutil.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/sbin/scutil'
}

koopa::macos_locate_softwareupdate() { # {{{1
    # """
    # Locate macOS softwareupdate.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/sbin/automount'
}

koopa::macos_locate_xattr() { # {{{1
    # """
    # Locate macOS xattr.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/xattr'
}

koopa::macos_locate_xcode_select() { # {{{1
    # """
    # Locate macOS xcode-select.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/xcode-select'
}

koopa::macos_locate_xcodebuild() { # {{{1
    # """
    # Locate macOS xcodebuild.
    # @note Updated 2021-11-16.
    # """
    koopa:::locate_app '/usr/bin/xcodebuild'
}
