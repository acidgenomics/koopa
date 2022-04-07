#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Microsoft OneDrive.
    # @note Updated 2021-10-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_rm --sudo \
        '/Applications/OneDrive.app'
    koopa_rm \
        "${HOME}/Library/Containers/com.microsoft.OneDrive-mac.FinderSync" \
        "${HOME}/Library/Application Scripts/\
com.microsoft.OneDrive-mac.FinderSync" \
        "${HOME}/Library/Group Containers/UBF8T346G9.OneDriveSyncClientSuite"
    return 0
}
