#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

main() { # {{{1
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
