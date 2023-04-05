#!/usr/bin/env bash

koopa_pager() {
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2023-04-05.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local -A app
    local -a args
    koopa_assert_has_args "$#"
    app['less']="$(koopa_locate_less --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    args=("$@")
    koopa_assert_is_file "${args[-1]}"
    "${app['less']}" -R "${args[@]}"
    return 0
}
