#!/usr/bin/env bash

_koopa_app_dependencies() {
    # """
    # Get the dependencies of an app.
    # @note Updated 2023-12-11.
    #
    # @examples
    # _koopa_app_dependencies 'python3.13'
    # """
    _koopa_assert_has_args_eq "$#" 1
    _koopa_python_script 'app-dependencies.py' "$@"
}
