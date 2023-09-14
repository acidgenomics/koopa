#!/usr/bin/env bash

koopa_app_json() {
    # """
    # Parse 'app.json' file using our internal Python JSON parser.
    # @note Updated 2023-09-14.
    #
    # @examples
    # koopa_app_json \
    #     --app-name='coreutils' \
    #     --key='bin'
    # """
    local cmd
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'python3'
    cmd="$(koopa_koopa_prefix)/lang/python/app-json.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$@"
    return 0
}
