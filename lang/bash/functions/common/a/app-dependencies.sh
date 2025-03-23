#!/usr/bin/env bash

koopa_app_dependencies() {
    # """
    # Get the dependencies of an app.
    # @note Updated 2023-12-11.
    #
    # @examples
    # koopa_app_dependencies 'python3.12'
    # """
    koopa_assert_has_args_eq "$#" 1
    koopa_python_script 'app-dependencies.py' "$@"
    return 0
}
