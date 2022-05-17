#!/usr/bin/env bash

koopa_kebab_case_simple() {
    # """
    # Simple snake case function.
    # @note Updated 2022-03-01.
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
    local args str
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
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
