#!/usr/bin/env bash

koopa_parse_app_json() {
    # """
    # Parse 'app.json' file using our internal Python JSON parser.
    # @note Updated 2022-08-23.
    # """
    local cmd
    koopa_assert_has_args "$#"
    cmd="$(koopa_koopa_prefix)/lang/python/parse-app-json.py"
    koopa_assert_is_executable "$cmd"
    "$cmd" "$@"
}
