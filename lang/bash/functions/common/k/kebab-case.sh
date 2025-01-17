#!/usr/bin/env bash

koopa_kebab_case() {
    # """
    # Apply snake case formatting.
    # @note Updated 2023-06-05.
    #
    # @seealso
    # - syntactic R package.
    #
    # @examples
    # > koopa_kebab_case 'hello world'
    # # hello-world
    #
    # > koopa_kebab_case 'bcbio-nextgen.py'
    # # bcbio-nextgen-py
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
            --pattern='[^-A-Za-z0-9]' \
            --regex \
            --replacement='-' \
            "$@" \
        | koopa_lowercase \
    )"
    koopa_is_array_non_empty "${out[@]:-}" || return 1
    koopa_print "${out[@]}"
    return 0
}
