#!/usr/bin/env bash

koopa_lowercase() {
    # """
    # Transform string to lowercase.
    # @note Updated 2022-08-30.
    #
    # awk alternative:
    # > koopa_print "$str" | "${app['awk']}" '{print tolower($0)}'
    #
    # @seealso
    # - https://stackoverflow.com/questions/2264428
    #
    # @examples
    # > koopa_lowercase 'HELLO WORLD'
    # # hello world
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
        koopa_print "$str" \
            | "${app['tr']}" '[:upper:]' '[:lower:]'
    done
    return 0
}
