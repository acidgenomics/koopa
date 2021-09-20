#!/usr/bin/env bash

koopa::macos_update_google_cloud_sdk() { # {{{1
    local brew name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='Google Cloud SDK'
    koopa::update_start "$name_fancy"
    brew="$(koopa::locate_brew)"
    "$brew" reinstall --cask 'google-cloud-sdk'
    koopa::update_success "$name_fancy"
    return 0
}
