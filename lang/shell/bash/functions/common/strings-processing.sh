#!/usr/bin/env bash

koopa::capitalize() { # {{{1
    # """
    # Capitalize the first letter (only) of a string.
    # @note Updated 2021-05-21.
    #
    # @examples
    # koopa::capitalize 'hello world' 'foo bar'
    # ## 'Hello world' 'Foo bar'
    # @seealso
    # - https://stackoverflow.com/a/12487465
    # """
    local str tr
    koopa::assert_has_args "$#"
    tr="$(koopa::locate_tr)"
    for str in "$@"
    do
        str="$("$tr" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
        koopa::print "$str"
    done
    return 0
}

koopa::paste0() { # {{{1
    # """
    # Paste arguments (e.g. from an array) into a string separated by delimiter
    # defined in the first positional argument.
    # @note Updated 2021-05-21.
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
    koopa::print "$str"
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
