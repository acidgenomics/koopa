#!/usr/bin/env bash

koopa_macos_enable_gpg_updater() {
    # """
    # Enable GPG tools updater.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}
