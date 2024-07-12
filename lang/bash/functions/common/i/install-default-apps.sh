#!/usr/bin/env bash

koopa_install_default_apps() {
    # """
    # Install default apps.
    # @note Updated 2024-07-12.
    # """
    koopa_assert_has_no_args "$#"
    koopa_install_shared_apps "$@"
    return 0
}
