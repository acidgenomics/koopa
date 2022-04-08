#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Google Cloud SDK.
    # @note Updated 2022-01-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_remove 'google-cloud-sdk'
    return 0
}
