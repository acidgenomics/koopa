#!/usr/bin/env bash

koopa_install_all_supported() {
    # """
    # Install all supported apps.
    # @note Updated 2023-10-13.
    # """
    koopa_assert_has_no_args "$#"
    koopa_install_shared_apps --all-supported "$@"
    return 0
}
