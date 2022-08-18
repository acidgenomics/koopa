#!/usr/bin/env bash

# FIXME Need to link into koopa bin.

main() {
    # """
    # Install Google Cloud SDK.
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-yum
    # """
    koopa_assert_has_no_args "$#"
    koopa_fedora_add_google_cloud_sdk_repo
    koopa_fedora_dnf_install 'google-cloud-sdk'
    return 0
}
