#!/usr/bin/env bash

koopa_install_all_supported() {
    # """
    # Install all supported apps.
    # @note Updated 2023-12-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_install_shared_apps --all "$@"
    return 0
}
