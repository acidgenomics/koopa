#!/usr/bin/env bash

koopa_shared_apps() {
    # """
    # Enabled shared apps to be installed by default.
    # @note Updated 2023-03-27.
    #
    # @examples
    # koopa_shared_apps
    # """
    local cmd
    koopa_assert_has_no_args "$#"
    cmd="$(koopa_koopa_prefix)/lang/python/shared-apps.py"
    koopa_assert_is_executable "$cmd"
    "$cmd"
    return 0
}
