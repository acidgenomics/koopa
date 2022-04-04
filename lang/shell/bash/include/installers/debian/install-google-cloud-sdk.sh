#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

debian_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2022-01-27.
    #
    # Required packages:
    # - apt-transport-https
    # - ca-certificates
    # - curl
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-apt-get
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_debian_apt_add_google_cloud_sdk_repo
    koopa_debian_apt_install 'google-cloud-sdk'
    return 0
}
