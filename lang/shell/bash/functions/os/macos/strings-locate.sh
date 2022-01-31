#!/usr/bin/env bash

koopa::macos_locate_automount() { # {{{1
    koopa::locate_app '/usr/sbin/automount'
}

koopa::macos_locate_defaults() { # {{{1
    koopa::locate_app '/usr/bin/defaults'
}

koopa::macos_locate_diskutil() { # {{{1
    koopa::locate_app '/usr/sbin/diskutil'
}

koopa::macos_locate_dscacheutil() { # {{{1
    koopa::locate_app '/usr/bin/dscacheutil'
}

koopa::macos_locate_hdiutil() { # {{{1
    koopa::locate_app '/usr/bin/hdiutil'
}

koopa::macos_locate_ifconfig() { # {{{1
    koopa::locate_app '/sbin/ifconfig'
}

koopa::macos_locate_installer() { # {{{1
    koopa::locate_app '/usr/sbin/installer'
}

koopa::macos_locate_kill_all() { # {{{1
    koopa::locate_app '/usr/bin/killAll'
}

koopa::macos_locate_launchctl() { # {{{1
    koopa::locate_app '/bin/launchctl'
}

koopa::macos_locate_lsregister() { # {{{1
    koopa::locate_app "/System/Library/Frameworks/CoreServices.framework\
/Frameworks/LaunchServices.framework/Support/lsregister"
}

koopa::macos_locate_mas() { # {{{1
    koopa::locate_app 'mas'
}

koopa::macos_locate_nfsstat() { # {{{1
    koopa::locate_app '/usr/bin/nfsstat'
}

koopa::macos_locate_nvram() { # {{{1
    koopa::locate_app '/usr/sbin/nvram'
}

koopa::macos_locate_open() { # {{{1
    koopa::locate_app '/usr/bin/open'
}

koopa::macos_locate_pkgutil() { # {{{1
    koopa::locate_app '/usr/sbin/pkgutil'
}

koopa::macos_locate_plistbuddy() { # {{{1
    koopa::locate_app '/usr/libexec/PlistBuddy'
}

koopa::macos_locate_plutil() { # {{{1
    koopa::locate_app '/usr/bin/plutil'
}

koopa::macos_locate_pmset() { # {{{1
    koopa::locate_app '/usr/bin/pmset'
}

koopa::macos_locate_reboot() { # {{{1
    koopa::locate_app '/sbin/reboot'
}

koopa::macos_locate_scutil() { # {{{1
    koopa::locate_app '/usr/sbin/scutil'
}

koopa::macos_locate_softwareupdate() { # {{{1
    koopa::locate_app '/usr/sbin/softwareupdate'
}

koopa::macos_locate_sw_vers() { # {{{1
    koopa::locate_app '/usr/bin/sw_vers'
}

koopa::macos_locate_sysctl() { # {{{1
    koopa::locate_app '/usr/sbin/sysctl'
}

koopa::macos_locate_xattr() { # {{{1
    koopa::locate_app '/usr/bin/xattr'
}

koopa::macos_locate_xcode_select() { # {{{1
    koopa::locate_app '/usr/bin/xcode-select'
}

koopa::macos_locate_xcodebuild() { # {{{1
    koopa::locate_app '/usr/bin/xcodebuild'
}
