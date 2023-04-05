#!/usr/bin/env bash

koopa_capitalize() {
    # """
    # Capitalize the first letter (only) of a string.
    # @note Updated 2022-07-15.
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
    local app str
    local -A app
    app['tr']="$(koopa_locate_tr --allow-system)"
    [[ -x "${app['tr']}" ]] || exit 1
    if [[ "$#" -eq 0 ]]
    then
        local pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$("${app['tr']}" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
        koopa_print "$str"
    done
    return 0
}
