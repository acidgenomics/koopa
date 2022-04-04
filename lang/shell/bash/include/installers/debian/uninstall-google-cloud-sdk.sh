#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

debian_uninstall_google_cloud_sdk() { # {{{1
    # """
    # Uninstall Google Cloud SDK.
    # @note Updated 2022-01-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_debian_apt_remove 'google-cloud-sdk'
    return 0
}
