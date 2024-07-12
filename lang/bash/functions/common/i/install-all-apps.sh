#!/usr/bin/env bash

koopa_install_all_apps() {
    # """
    # Install all (supported) apps.
    # @note Updated 2024-07-12.
    # """
    koopa_assert_has_no_args "$#"
    koopa_install_shared_apps --all "$@"
    return 0
}
