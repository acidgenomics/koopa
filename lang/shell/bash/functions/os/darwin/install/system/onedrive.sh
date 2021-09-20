#!/usr/bin/env bash

koopa::macos_uninstall_onedrive() { # {{{1
    # """
    # Uninstall Microsoft OneDrive.
    # @note Updated 2020-07-20.
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='Microsoft OneDrive'
    koopa::uninstall_start "$name_fancy"
    koopa::rm \
        "${HOME}/Library/Containers/com.microsoft.OneDrive-mac.FinderSync" \
        "${HOME}/Library/Application Scripts/\
com.microsoft.OneDrive-mac.FinderSync" \
        "${HOME}/Library/Group Containers/UBF8T346G9.OneDriveSyncClientSuite"
    koopa::rm -S '/Applications/OneDrive.app'
    koopa::uninstall_success "$name_fancy"
    return 0
}
