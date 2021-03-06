#!/usr/bin/env bash

koopa::paste0() { # {{{1
    # """
    # Paste arguments (e.g. from an array) into a string separated by delimiter
    # defined in the first positional argument.
    # @note Updated 2020-07-01.
    #
    # Note that the 'paste0' name is a reference to the R function.
    #
    # @params
    # $1: The delimiter string
    # ${@:2}: The arguments to join
    #
    # @return
    # >&1: The arguments separated by the delimiter string
    #
    # See also:
    # - https://stackoverflow.com/questions/13470413
    # - https://stackoverflow.com/a/57536163/3911732
    # - https://stackoverflow.com/questions/1527049/
    # """
    # Require at least the delimiter.
    (($#)) || return 1
    local -- delim="$1" str IFS=
    shift 1
    # Expand arguments with prefixed delimiter (Empty IFS).
    str="${*/#/$delim}"
    # Print without the first delimiter.
    str="${str:${#delim}}"
    printf '%s\n' "$str"
    return 0
}

koopa::to_string() { # {{{1
    # """
    # Paste arguments to a comma separated string.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    koopa::paste0 ', ' "$@"
    return 0
}
