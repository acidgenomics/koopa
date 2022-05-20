#!/usr/bin/env bash

koopa_lowercase() {
    # """
    # Transform string to lowercase.
    # @note Updated 2022-03-01.
    #
    # awk alternative:
    # > koopa_print "$str" | "${app[awk]}" '{print tolower($0)}'
    #
    # @seealso
    # - https://stackoverflow.com/questions/2264428
    #
    # @examples
    # > koopa_lowercase 'HELLO WORLD'
    # # hello world
    # """
    local app args str
    koopa_assert_has_args "$#"
    declare -A app=(
        [tr]="$(koopa_locate_tr)"
    )
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
        koopa_print "$str" \
            | "${app[tr]}" '[:upper:]' '[:lower:]'
    done
    return 0
}
