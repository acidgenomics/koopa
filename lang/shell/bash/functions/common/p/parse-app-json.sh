#!/usr/bin/env bash

koopa_parse_app_json() {
    # """
    # Parse 'app.json' file using our internal Python JSON parser.
    # @note Updated 2023-03-20.
    #
    # @examples
    # koopa_parse_app_json \
    #     --app-name='coreutils' \
    #     --key='bin'
    # """
    local cmd
    koopa_assert_has_args "$#"
    cmd="$(koopa_koopa_prefix)/lang/python/app-json.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$@"
    return 0
}
