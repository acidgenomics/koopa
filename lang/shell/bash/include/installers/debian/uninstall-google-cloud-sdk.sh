#!/usr/bin/env bash

koopa:::debian_uninstall_google_cloud_sdk() { # {{{1
    # """
    # Uninstall Google Cloud SDK.
    # @note Updated 2022-01-27.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::debian_apt_remove 'google-cloud-sdk'
    return 0
}
