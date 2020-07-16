#!/usr/bin/env bash

koopa::macos_symlink_icloud_drive() {
    koopa::assert_has_no_args "$#"
    koopa::ln \
        "${HOME}/Library/Mobile Documents/com~apple~CloudDocs" \
        "${HOME}/icloud"
    return 0
}
