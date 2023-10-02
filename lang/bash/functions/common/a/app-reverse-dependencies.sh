#!/usr/bin/env bash

koopa_app_reverse_dependencies() {
    # """
    # Get the reverse dependencies of an app.
    # @note Updated 2023-09-14.
    #
    # @examples
    # koopa_app_reverse_dependencies 'python3.12'
    # """
    local app_name cmd
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_installed 'python3'
    app_name="${1:?}"
    cmd="$(koopa_koopa_prefix)/lang/python/app-reverse-dependencies.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$app_name"
    return 0
}
