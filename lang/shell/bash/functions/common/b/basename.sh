#!/usr/bin/env bash

koopa_basename() {
    # """
    # Extract the file basename.
    # @note Updated 2022-07-15.
    #
    # Parameterized, supporting multiple basename extractions.
    #
    # @seealso
    # - https://stackoverflow.com/questions/22401091/
    # """
    local arg
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for arg in "$@"
    do
        [[ -n "$arg" ]] || return 1
        koopa_print "${arg##*/}"
    done
    return 0
}
