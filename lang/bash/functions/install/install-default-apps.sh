#!/usr/bin/env bash

_koopa_install_default_apps() {
    # """
    # Install default apps.
    # @note Updated 2024-07-12.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_install_shared_apps "$@"
    return 0
}
