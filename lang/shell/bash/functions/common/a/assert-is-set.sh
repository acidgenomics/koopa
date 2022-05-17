#!/usr/bin/env bash

koopa_assert_is_set() {
    # """
    # Assert that variables are set (and not unbound).
    # @note Updated 2021-11-05.
    #
    # @examples
    # > declare -A dict=(
    # >     [aaa]='AAA'
    # >     [bbb]='BBB'
    # > )
    # > koopa_assert_is_set \
    # >     '--aaa' "${dict[aaa]:-}" \
    # >     '--bbb' "${dict[bbb]:-}"
    # """
    local name value
    koopa_assert_has_args_ge "$#" 2
    while (("$#"))
    do
        name="${1:?}"
        value="${2:-}"
        shift 2
        if [[ -z "${value}" ]]
        then
            koopa_stop "'${name}' is unset."
        fi
    done
    return 0
}
