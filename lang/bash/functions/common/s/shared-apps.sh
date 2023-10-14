#!/usr/bin/env bash

koopa_shared_apps() {
    # """
    # Enabled shared apps to be installed by default.
    # @note Updated 2023-10-13.
    #
    # @examples
    # koopa_shared_apps
    # """
    local cmd
    koopa_assert_is_installed 'python3'
    cmd="$(koopa_koopa_prefix)/lang/python/shared-apps.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$@"
    return 0
}
