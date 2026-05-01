#!/usr/bin/env bash

_koopa_app_reverse_dependencies() {
    # """
    # Get the reverse dependencies of an app.
    # @note Updated 2023-12-11.
    #
    # @examples
    # _koopa_app_reverse_dependencies 'python3.13'
    # """
    _koopa_assert_has_args_eq "$#" 1
    _koopa_python_script 'app-reverse-dependencies.py' "$@"
    return 0
}
