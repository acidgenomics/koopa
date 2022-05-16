#!/usr/bin/env bash

koopa_capitalize() {
    # """
    # Capitalize the first letter (only) of a string.
    # @note Updated 2022-03-01.
    #
    # @seealso
    # - https://stackoverflow.com/a/12487465
    #
    # @usage koopa_capitalize STRING...
    #
    # @examples
    # > koopa_capitalize 'hello world' 'foo bar'
    # # 'Hello world' 'Foo bar'
    # """
    local app args str
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
        str="$("${app[tr]}" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
        koopa_print "$str"
    done
    return 0
}
