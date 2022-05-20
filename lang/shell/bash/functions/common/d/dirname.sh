#!/usr/bin/env bash

koopa_dirname() {
    # """
    # Extract the file dirname.
    # @note Updated 2021-05-27.
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
        if [[ -e "$arg" ]]
        then
            arg="$(koopa_realpath "$arg")"
        fi
        koopa_print "${arg%/*}"
    done
    return 0
}
