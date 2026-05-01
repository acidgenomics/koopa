#!/usr/bin/env bash

_koopa_install_all_apps() {
    # """
    # Install all (supported) apps.
    # @note Updated 2024-07-12.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_install_shared_apps --all "$@"
    return 0
}
