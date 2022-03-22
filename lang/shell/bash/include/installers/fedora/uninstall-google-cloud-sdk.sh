#!/usr/bin/env bash

fedora_uninstall_google_cloud_sdk() { # {{{1
    # """
    # Uninstall Google Cloud SDK.
    # @note Updated 2022-01-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_fedora_dnf_remove 'google-cloud-sdk'
    koopa_fedora_dnf_delete_repo 'google-cloud-sdk'
    return 0
}
