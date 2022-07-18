#!/usr/bin/env bash

koopa_snake_case_simple() {
    # """
    # Simple snake case function.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - syntactic R package.
    #
    # @examples
    # > koopa_snake_case_simple 'hello world'
    # # hello_world
    #
    # > koopa_snake_case_simple 'bcbio-nextgen.py'
    # # bcbio_nextgen_py
    # """
    local str
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$( \
            koopa_gsub \
                --pattern='[^A-Za-z0-9_]' \
                --regex \
                --replacement='_' \
                "$str" \
        )"
        str="$(koopa_lowercase "$str")"
        koopa_print "$str"
    done
    return 0
}
