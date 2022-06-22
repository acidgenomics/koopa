#!/usr/bin/env bash

koopa_dirname() {
    # """
    # Extract the file dirname.
    # @note Updated 2022-06-22.
    #
    # Parameterized, supporting multiple basename extractions.
    #
    # @seealso
    # - https://stackoverflow.com/questions/22401091/
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        local str
        if [[ -e "$arg" ]]
        then
            arg="$(koopa_realpath "$arg")"
        fi
        if koopa_str_detect_fixed --string="$arg" --pattern='/'
        then
            str="${arg%/*}"
        else
            str='.'
        fi
        koopa_print "$str"
    done
    return 0
}
