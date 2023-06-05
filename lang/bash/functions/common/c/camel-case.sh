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
    local str
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$( \
            koopa_gsub \
                --pattern='([ -_])([a-z])' \
                --regex \
                --replacement='\U\2' \
                "$str" \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}
