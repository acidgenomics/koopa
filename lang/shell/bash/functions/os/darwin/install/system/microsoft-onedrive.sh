#!/usr/bin/env bash

koopa::macos_uninstall_microsoft_onedrive() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Microsoft OneDrive' \
        --name='microsoft-onedrive' \
        --platform='macos' \
        --system \
        "$@"
}

koopa:::macos_uninstall_microsoft_onedrive() { # {{{1
    # """
    # Uninstall Microsoft OneDrive.
    # @note Updated 2021-10-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::rm --sudo \
        '/Applications/OneDrive.app'
    koopa::rm \
        "${HOME}/Library/Containers/com.microsoft.OneDrive-mac.FinderSync" \
        "${HOME}/Library/Application Scripts/\
com.microsoft.OneDrive-mac.FinderSync" \
        "${HOME}/Library/Group Containers/UBF8T346G9.OneDriveSyncClientSuite"
    return 0
}
