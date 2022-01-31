#!/usr/bin/env bash

koopa:::fedora_uninstall_google_cloud_sdk() { # {{{1
    # """
    # Uninstall Google Cloud SDK.
    # @note Updated 2022-01-27.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::fedora_dnf_remove 'google-cloud-sdk'
    koopa::fedora_dnf_delete_repo 'google-cloud-sdk'
    return 0
}
