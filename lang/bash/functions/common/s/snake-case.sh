#!/usr/bin/env bash

koopa_snake_case() {
    # """
    # Apply snake case formatting.
    # @note Updated 2023-06-05.
    #
    # @seealso
    # - syntactic R package.
    #
    # @examples
    # > koopa_snake_case 'hello world'
    # # hello_world
    #
    # > koopa_snake_case 'bcbio-nextgen.py'
    # # bcbio_nextgen_py
    # """
    local -a out
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    readarray -t out <<< "$( \
        koopa_gsub \
            --pattern='[^A-Za-z0-9_]' \
            --regex \
            --replacement='_' \
            "$@" \
        | koopa_lowercase \
    )"
    koopa_is_array_non_empty "${out[@]:-}" || return 1
    koopa_print "${out[@]}"
    return 0
}
