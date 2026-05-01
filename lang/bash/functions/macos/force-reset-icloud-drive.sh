#!/usr/bin/env bash

_koopa_macos_force_reset_icloud_drive() {
    # """
    # Force reset iCloud Drive.
    # @note Updated 2023-05-01.
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
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    app['reboot']="$(_koopa_macos_locate_reboot)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['kill_all']}" bird
    _koopa_rm \
        "${HOME:?}/Library/Application Support/CloudDocs" \
        "${HOME:?}/Library/Caches/"*
    _koopa_sudo "${app['reboot']}" now
    return 0
}
