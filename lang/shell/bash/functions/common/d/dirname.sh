#!/usr/bin/env bash

koopa_dirname() {
    # """
    # Extract the file dirname.
    # @note Updated 2022-07-15.
    #
    # Parameterized, supporting multiple basename extractions.
    #
    # @seealso
    # - https://stackoverflow.com/questions/22401091/
    # """
    local arg pos
    pos=("$@")
    [[ "${#pos[@]}" -eq 0 ]] && pos=("$(</dev/stdin)")
    for arg in "${pos[@]}"
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
