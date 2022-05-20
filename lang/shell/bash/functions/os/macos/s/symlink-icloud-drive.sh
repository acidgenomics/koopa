#!/usr/bin/env bash

koopa_macos_symlink_icloud_drive() {
    # """
    # Symlink iCloud Drive into user home directory.
    # @note Updated 2021-10-29.
    # """
    koopa_assert_has_no_args "$#"
    koopa_ln \
        "${HOME}/Library/Mobile Documents/com~apple~CloudDocs" \
        "${HOME}/icloud"
    return 0
}
