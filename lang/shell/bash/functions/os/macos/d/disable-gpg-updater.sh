#!/usr/bin/env bash

koopa_macos_disable_gpg_updater() {
    # """
    # Disable GPG tools updater.
    # @note Updated 2022-02-16.
    # """
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}
