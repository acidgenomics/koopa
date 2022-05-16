#!/usr/bin/env bash

koopa_camel_case_simple() {
    # """
    # Simple camel case function.
    # @note Updated 2022-04-26.
    #
    # @seealso
    # - syntactic R package.
    # - https://stackoverflow.com/questions/34420091/
    #
    # @usage koopa_camel_case_simple STRING...
    #
    # @examples
    # > koopa_camel_case_simple 'hello world'
    # # helloWorld
    # """
    local args str
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
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
