#!/usr/bin/env bash

_koopa_macos_disable_gpg_updater() {
    # """
    # Disable GPG tools updater.
    # @note Updated 2022-02-16.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_macos_disable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}
