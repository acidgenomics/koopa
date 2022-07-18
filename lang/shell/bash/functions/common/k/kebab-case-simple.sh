#!/usr/bin/env bash

koopa_kebab_case_simple() {
    # """
    # Simple snake case function.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - syntactic R package.
    #
    # @examples
    # > koopa_kebab_case_simple 'hello world'
    # # hello-world
    #
    # > koopa_kebab_case_simple 'bcbio-nextgen.py'
    # # bcbio-nextgen-py
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
        str="$(\
            koopa_gsub \
                --pattern='[^-A-Za-z0-9]' \
                --regex \
                --replacement='-' \
                "$str" \
        )"
        str="$(koopa_lowercase "$str")"
        koopa_print "$str"
    done
    return 0
}
