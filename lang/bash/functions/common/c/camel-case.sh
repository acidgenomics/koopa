#!/usr/bin/env bash

koopa_camel_case() {
    # """
    # Apply camel case formatting.
    # @note Updated 2023-06-05.
    #
    # @seealso
    # - syntactic R package.
    # - https://stackoverflow.com/questions/34420091/
    #
    # @usage koopa_camel_case STRING...
    #
    # @examples
    # > koopa_camel_case 'hello world'
    # # helloWorld
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
            --pattern='([ -_])([a-z])' \
            --regex \
            --replacement='\U\2' \
            "$@" \
    )"
    koopa_is_array_non_empty "${out[@]:-}" || return 1
    koopa_print "${out[@]}"
    return 0
}
