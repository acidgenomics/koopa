#!/usr/bin/env bash

koopa_app_reverse_dependencies() {
    # """
    # Get the reverse dependencies of an app.
    # @note Updated 2023-12-11.
    #
    # @examples
    # koopa_app_reverse_dependencies 'python3.12'
    # """
    koopa_assert_has_args_eq "$#" 1
    koopa_python_script 'app-reverse-dependencies.py' "$@"
    return 0
}
