#!/usr/bin/env bash

koopa::macos_force_reset_icloud_drive() { # {{{1
    # """
    # Force reset iCloud Drive.
    # @note Updated 2021-11-16.
    #
    # iCloud Drive is located here:
    # "${HOME}/Library/Mobile Documents/com~apple~CloudDocs"
    #
    # - Check your Internet connection.
    # - Go into iCloud settings and turn off iCloud Drive.
    # - Then log out of iCloud.
    # - Reboot.
    #
    # Close Safari.
    # Nuke the old Safari bookmarks.
    # Note that this will remove the reading list.
    # > rm '/Users/mike/Library/Safari/Bookmarks.plist'
    # > rm -rf '/Users/mike/Library/Safari/CloudBookmarksMigrationCoordinator'
    #
    # > sudo brctl log --wait --shorten
    # error while reading logs: <NSError:0x7fd360d01990(NSPOSIXErrorDomain:5)
    #
    # Remove bird?
    # > sudo launchctl remove 'com.apple.bird'
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [kill_all]="$(koopa::macos_locate_kill_all)"
        [reboot]="$(koopa::macos_locate_reboot)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[kill_all]}" bird
    koopa::rm \
        "${HOME:?}/Library/Application Support/CloudDocs" \
        "${HOME:?}/Library/Caches/"*
    "${app[sudo]}" "${app[reboot]}" now
    return 0
}

koopa::macos_symlink_icloud_drive() { # {{{1
    # """
    # Symlink iCloud Drive into user home directory.
    # @note Updated 2021-10-29.
    # """
    koopa::assert_has_no_args "$#"
    koopa::ln \
        "${HOME}/Library/Mobile Documents/com~apple~CloudDocs" \
        "${HOME}/icloud"
    return 0
}
