#!/usr/bin/env bash

koopa::pager() { # {{{1
    # """
    # Run less with support for colors (escape characters).
    # @note Updated 2020-07-03.
    #
    # Detail on handling escape sequences:
    # https://major.io/2013/05/21/
    #     handling-terminal-color-escape-sequences-in-less/
    # """
    local pager
    pager="${PAGER:-less}"
    koopa::assert_is_installed "$pager"
    "$pager" -R "$@"
    return 0
}
