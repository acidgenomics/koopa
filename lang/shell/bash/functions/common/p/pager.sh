#!/usr/bin/env bash

koopa_pager() {
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2022-02-15.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local app args
    koopa_assert_has_args "$#"
    declare -A app=(
        [less]="$(koopa_locate_less)"
    )
    args=("$@")
    koopa_assert_is_file "${args[-1]}"
    "${app[less]}" -R "${args[@]}"
    return 0
}
