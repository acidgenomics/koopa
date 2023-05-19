#!/usr/bin/env bash

koopa_basename() {
    # """
    # Extract the file basename.
    # @note Updated 2023-01-27.
    #
    # Parameterized, supporting multiple basename extractions.
    #
    # @seealso
    # - https://stackoverflow.com/questions/22401091/
    # - https://stackoverflow.com/questions/9018723/
    # - http://wiki.bash-hackers.org/syntax/pattern
    # """
    local arg
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for arg in "$@"
    do
        [[ -n "$arg" ]] || return 1
        arg="${arg%%+(/)}"
        arg="${arg##*/}"
        koopa_print "$arg"
    done
    return 0
}
