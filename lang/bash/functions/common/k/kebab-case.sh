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
