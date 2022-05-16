#!/usr/bin/env bash

koopa_contains() {
    # """
    # Does an array contain a specific element?
    # @note Updated 2021-05-07.
    #
    # @seealso
    # https://stackoverflow.com/questions/3685970/
    #
    # @examples
    # > string='foo'
    # > array=('foo' 'bar')
    # > koopa_contains "$string" "${array[@]}"
    # """
    local string x
    koopa_assert_has_args_ge "$#" 2
    string="${1:?}"
    shift 1
    for x
    do
        [[ "$x" == "$string" ]] && return 0
    done
    return 1
}
