#!/usr/bin/env bash

koopa_install_all_default() {
    # """
    # Install all default apps.
    # @note Updated 2023-12-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_install_shared_apps "$@"
    return 0
}
