#!/usr/bin/env bash

_koopa_dirname() {
    # """
    # Extract the file dirname.
    # @note Updated 2022-08-30.
    #
    # Parameterized, supporting multiple basename extractions.
    #
    # @seealso
    # - https://stackoverflow.com/questions/22401091/
    #
    # @examples
    # > _koopa_dirname '/usr/local/bin' '/tmp/xxx/yyy'
    # # /usr/local
    # # /tmp/xxx
    # """
    local arg
    if [[ "$#" -eq 0 ]]
    then
        local -a pos
        readarray -t pos <<< "$(</dev/stdin)"
        set -- "${pos[@]}"
    fi
    for arg in "$@"
    do
        local str
        [[ -n "$arg" ]] || return 1
        if [[ -e "$arg" ]]
        then
            arg="$(_koopa_realpath "$arg")"
        fi
        if _koopa_str_detect_fixed --string="$arg" --pattern='/'
        then
            str="${arg%/*}"
        else
            str='.'
        fi
        _koopa_print "$str"
    done
    return 0
}
