#!/usr/bin/env bash

koopa_to_string() {
    # """
    # Paste arguments to a comma separated string.
    # @note Updated 2023-03-18.
    #
    # @examples
    # > koopa_to_string 'aaa' 'bbb'
    # # aaa, bbb
    # """
    koopa_assert_has_args "$#"
    koopa_paste --sep=', ' "$@"
    return 0
}
