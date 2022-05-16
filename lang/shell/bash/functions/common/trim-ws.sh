#!/usr/bin/env bash

koopa_trim_ws() {
    # """
    # Trim leading and trailing white-space from string.
    # @note Updated 2022-03-01.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # We're allowing empty string input in this function.
    #
    # @examples
    # > koopa_trim_ws '  hello world  ' ' foo bar '
    # # hello world
    # # foo bar
    # """
    local args str
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
        str="${str#"${str%%[![:space:]]*}"}"
        str="${str%"${str##*[![:space:]]}"}"
        koopa_print "$str"
    done
    return 0
}
